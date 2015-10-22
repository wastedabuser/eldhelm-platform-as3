package eldhelm.network {
	import eldhelm.config.Servers;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class LoaderPoolSound extends LoaderPool {
		
		public function LoaderPoolSound(config:Object = null) {
			super(config);
			debugName = "sound loader";
		}
		
		protected function createSound():Sound {
			var loader:Sound = new Sound();
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus, false, 0, true);
			loader.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIoError, false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
			loader.addEventListener(ErrorEvent.ERROR, onError, false, 0, true);
			loaders.push(loader);
			return loader;
		}
		
		override protected function onComplete(event:Event):void {
			var sound:Sound = event.target as Sound;
			delete tempProgress[sound];
			var url:String = sound.url;
			data[urlLookUp[url]] = sound;
			super.onComplete(event);
			skip();
		}
		
		protected function onIoError(event:IOErrorEvent):void {
			trace(event);
			skip();
		}
		
		protected function onSecurityError(event:SecurityErrorEvent):void {
			trace(event);
			skip();
		}
		
		protected function onError(event:ErrorEvent):void {
			trace(event);
			skip();
		}
		
		protected function skip():void {
			loadedCount++;
			loadNext();
		}
		
		override public function load(list:Array, download:Boolean):void {
			if (list != null) pend(list, download);
			if (!loading) {
				loading = true;
				loadedCount = 0;
				for (var i:int = 0; i < Servers.cdnMaxConnections; i++) {
					if (!loadNext()) break;
				}
			}
		}
		
		public function loadNext():Boolean {
			var url:String = realUrls.shift();
			if (url != null) {
				try {
					var loader:Sound = createSound();
					loader.load(new URLRequest(url));
				} catch (e:Error) {
					trace(e);
					skip();
				}
				return true;
			} else if (loadedCount >= urlCount) {
				onAllComplete();
			}
			return false;
		}
		
		override public function destroy():void {
			for (var i:int = 0; i < loaders.length; i++) {
				var loader:Sound = loaders[i];
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				loader.removeEventListener(ErrorEvent.ERROR, onError);
			}
			super.destroy();
		}
		
	}

}