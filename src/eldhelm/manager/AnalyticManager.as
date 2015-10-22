package eldhelm.manager {
	import eldhelm.config.ContentVersion;
	import eldhelm.config.Servers;
	import eldhelm.constant.EldAnalyticConstant;
	import eldhelm.constant.EldEventConstant;
	import eldhelm.event.RequestEvent;
	import eldhelm.network.Request;
	import eldhelm.storage.FlushStorage;
	import eldhelm.storage.ProductUtil;
	import flash.net.URLRequestMethod;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AnalyticManager {
		
		public static const STORAGE_NS:String = "analytic";
		public static var storage:FlushStorage;
		public static var url:String;
		
		public static function start($url:String):void {
			url = $url;
			storage = new FlushStorage(STORAGE_NS);
			AppManager.callbackManager.bind(EldEventConstant.error, onError);
			AppManager.callbackManager.bind(EldEventConstant.exit, onExit);
			AppManager.callbackManager.bind(EldEventConstant.activate, onActivate);
			AppManager.callbackManager.bind(EldEventConstant.deactivate, onDeactivate);
			updateEnabled = true;
			
			push("device", {
				dpi: Capabilities.screenDPI,
				x: Capabilities.screenResolutionX,
				y: Capabilities.screenResolutionY,
				os: Capabilities.os,
				cpu: Capabilities.cpuArchitecture,
				lang: Capabilities.language,
				man: Capabilities.manufacturer,
				ver: ContentVersion.VERSION
			});
			flush();
			
			AppManager.timer.enable();
			AppManager.timer.callOnInterval(30, flush);
		}
		
		private static function onError(message:String):void {
			push(EldAnalyticConstant.error, message);
			flush();
		}
		
		private static function onExit():void {
			push("exit");
		}
		
		private static var updateEnabled:Boolean;
		private static function onActivate():void {
			updateEnabled = true;
			push("activate");
		}
		private static function onDeactivate():void {
			updateEnabled = false;
			push("deactivate");
			flush();
		}
		
		private static var frameCount:int;
		private static var frameTimeSec:Number;
		private static var timeSample:int;
		private static var maxFps:Number;
		private static var minFps:Number;
		
		public static function startUtilizationProbing():void {
			AppManager.timer.callEveryFrame(onUpdateFrameRate);
			AppManager.timer.callOnInterval(10, probe);
			frameCount = 0;
			frameTimeSec = 0;
			timeSample = getTimer();
			minFps = AppManager.frameRate;
			maxFps = 0;
		}
		
		public static function stopUtilizationProbing():void {
			AppManager.timer.remove(onUpdateFrameRate);
			AppManager.timer.remove(probe);
		}
		
		private static function onUpdateFrameRate():void {
			if (!updateEnabled) return;
			
			var curTimeSec:Number = (getTimer() - timeSample) / 1000; 
			timeSample = getTimer();
			
            frameCount++;
			frameTimeSec += curTimeSec;
			
			var fps:Number = 1 / curTimeSec;
			if (fps > maxFps) maxFps = fps;
			else if (fps < minFps) minFps = fps;
		}
		
		public static function probe():void {
			if (!updateEnabled) return;
			
			push("utilization", {
				mem: (System.totalMemory * 0.000000954).toFixed(2),
				fps: (frameCount / frameTimeSec).toFixed(2),
				maxFps: maxFps.toFixed(2),
				minFps: minFps.toFixed(2)
			});
			frameCount = 0;
			frameTimeSec = 0;
			maxFps = 0;
			minFps = AppManager.frameRate;
		}
		
		private static var benchmarks:Object = { };
		public static function startBenchmark(code:String):void {
			benchmarks[code] = getTimer();
		}
		
		public static function finishBenchmark(code:String, data:* = ""):void {
			if (!benchmarks[code]) return;
			
			push(code, data, getTimer() - benchmarks[code]);
			delete benchmarks[code];
		}
		
		public static function push(code:String, data:* = "", value:int = 0):void {
			var dt:Date = new Date,
				val:Number = dt.valueOf(),
				timestamp:int = int(val / 1000),
				ms:int = val - (timestamp * 1000),
				content:String = "";
			
			if (data) {
				if (data is String) content = data;
				else if (data is Object) content = JSON.stringify(data);
			}
			
			storage.push([code, content, value, timestamp, ms]);
		}
		
		public static function flush():void {
			if (!updateEnabled) return;
			
			var data:Array = storage.export();
			if (!data) return;
			
			Request.execute( {
				host: Servers.analyticUrl,
				url: url,
				method: URLRequestMethod.POST,
				success: onSuccess,
				fail: onFail,
				params: {
					productId: ProductUtil.productID
				},
				data: data
			});
		}
		
		private static function onSuccess(event:RequestEvent):void {
			var content:String = event.content;
			if (!content) return;
			
			storage.flush(content.split(","));
			retry = 3;
		}
		
		private static var retry:int = 3;
		private static function onFail(event:RequestEvent):void {
			trace("Failed to send analytic on retry: " + retry);
			retry--;
			if (!retry) AppManager.timer.remove(flush);
		}
		
	}

}