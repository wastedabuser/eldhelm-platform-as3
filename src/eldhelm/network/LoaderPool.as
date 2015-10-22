package eldhelm.network {
	import eldhelm.config.Servers;
	import eldhelm.event.LoaderPoolEvent;
	import eldhelm.interfaces.ILoaderPool;
	import eldhelm.manager.AppManager;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.ProgressEvent;
	import flash.system.Security;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class LoaderPool extends EventDispatcher implements ILoaderPool {
		
		public static var policyLoaded:Boolean;
		
		public var dirPrefix:String;
		public var data:Object = { };
		public var loading:Boolean = false;
		
		protected var _urlPrefix:String = "";
		protected var realUrls:Array = [];
		protected var urlLookUp:Object = {};
		protected var fullUrlLookUp:Object = {};
		protected var loaders:Array = [];
		protected var urlCount:int = 0;
		protected var loadedCount:int = 0;
		protected var tempProgress:Dictionary = new Dictionary;
		
		protected var success:Function;
		protected var itemSuccess:Function;
		protected var itemError:Function;
		protected var debugName:String;
		protected var showLog:Boolean;
		
		public function LoaderPool(config:Object = null) {
			if (config) {
				if (config.debugName) debugName = config.debugName;
				if (config.urlPrefix) _urlPrefix = config.urlPrefix;
				if (config.dirPrefix) dirPrefix = config.dirPrefix;
				if (config.urls) pend(config.urls);
				if (config.itemSuccess) {
					itemSuccess = config.itemSuccess;
					addEventListener(LoaderPoolEvent.ON_ITEM_SUCCESS, itemSuccess, false, 0, true);
				}
				if (config.success) {
					success = config.success;
					addEventListener(LoaderPoolEvent.ON_SUCCESS, success, false, 0, true);
				}
				if (config.itemError) {
					itemError = config.itemError;
					addEventListener(LoaderPoolEvent.ON_ITEM_ERROR, itemError, false, 0, true);
				}
			}
			//showLog = CONFIG::debug;
		}
		
		public function get urlPrefix():String {
			return Servers.httpPref + Servers.cdnServer + _urlPrefix;
		}
		
		public function load(list:Array, download:Boolean):void {
			
		}
		
		public function pend(list:Array, download:Boolean = false):void {
			if (!policyLoaded && AppManager.isWeb) {
				policyLoaded = true;
				Security.loadPolicyFile(urlPrefix + "/crossdomain.xml");
			}			
			if (showLog) trace("[" + debugName + "] Pending started: " + list.length);
			var obj:Object = {};
			for (var i:int = 0; i < list.length; i++) {
				if (list[i]) obj[list[i]] = 1;
			}
			var fullUrl:String;
			for (var z:String in obj) {
				fullUrl = (dirPrefix && !download ? dirPrefix : urlPrefix) + z;
				realUrls.push(fullUrl);
				urlLookUp[fullUrl] = z;
				fullUrlLookUp[z] = fullUrl;
				if (showLog) trace("[" + debugName + "] Pending: " + fullUrl);
				urlCount++;
			}
		}
		
		public function cancel(url:String):Boolean {
			var fullUrl:String = fullUrlLookUp[url],
				index:int;
			if (!fullUrl) return false;
			index = realUrls.indexOf(fullUrl);
			if (index < 0) return false;
			else realUrls.splice(index, 1);
			delete fullUrlLookUp[url];
			delete urlLookUp[fullUrl];
			urlCount--;
			return true;
		}
		
		protected function onHttpStatus(event:HTTPStatusEvent):void {
			//trace(event);
		}
		
		protected function dispatchError(url:String, error:String):void {
			dispatchEvent(new LoaderPoolEvent(LoaderPoolEvent.ON_ITEM_ERROR, {
				error: error,
				url: url
			} ));
		}
		
		protected function onProgress(event:ProgressEvent):void {
			tempProgress[event.target] = event.bytesLoaded / event.bytesTotal * 100 / urlCount;
			var inProgress:Number = 0;
			for (var i:Object in tempProgress) inProgress += tempProgress[i];
			var value:Number = loadedCount * 100 / urlCount + inProgress;
			if (isNaN(value) || !value) return;
			
			dispatchEvent(new LoaderPoolEvent(LoaderPoolEvent.ON_PROGRESS, {
				progress: value
			}));
		}
		
		protected function onComplete(event:Event):void {
			dispatchItemSuccess(event.target.url);
		}
		
		protected function dispatchItemSuccess(url:String):void {
			url = url.replace(urlPrefix, "");
			if (dirPrefix) url = url.replace(dirPrefix, "");
			if (showLog) trace("[" + debugName + "] Completed: " + url);
			dispatchEvent(new LoaderPoolEvent(LoaderPoolEvent.ON_ITEM_SUCCESS, {
				url: url,
				data: data
			} ));
		}
		
		protected function onAllComplete():void {
			urlCount = 0;
			loading = false;
			dispatchEvent(new LoaderPoolEvent(LoaderPoolEvent.ON_SUCCESS, { 
				data: data,
				progress: 100
			} ));
		}
		
		public function destroy():void {
			fullUrlLookUp = null;
			urlLookUp = null;
			tempProgress = null;
			realUrls.length = 0;
			realUrls = null;
			loaders.length = 0;
			loaders = null;
			data = null;
			if (success != null) {
				removeEventListener(LoaderPoolEvent.ON_SUCCESS, success);
				success = null;
			}
			if (itemSuccess != null) {
				removeEventListener(LoaderPoolEvent.ON_ITEM_SUCCESS, itemSuccess);
				itemSuccess = null;
			}
			if (itemError != null) {
				removeEventListener(LoaderPoolEvent.ON_ITEM_ERROR, itemError);
				itemError = null;
			}
		}
		
	}

}