package eldhelm.manager {
	import eldhelm.event.AssetLibraryEvent;
	import eldhelm.event.LoaderPoolEvent;
	import eldhelm.network.LoaderPool;
	import eldhelm.util.ObjectUtil;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class AssetLibrary extends EventDispatcher {
		
		public var assetLoader:LoaderPool;
		
		protected var library:Object = { };
		protected var pendingMap:Object = { };
		protected var callbackList:Array = [];
		protected var singleCallbacks:Object = { };
		protected var reloadingTimer:Timer;
		protected var reloadingList:Array = [];
		
		public function AssetLibrary() {
			super();
			
			reloadingTimer = new Timer(2000, 1);
			reloadingTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onReloadingtimer, false, 0, true);
		}
		
		protected function onAllLoaderSuccess(event:LoaderPoolEvent):void {
			for (var i:String in pendingMap) reloadingList.push(i);
			if (reloadingList.length > 0) {
				trace(reloadingList.length + " assets not loaded. Reloading...");
				ObjectUtil.emptyObject(pendingMap);
				reloadingTimer.start();
			} else 
				executeCallback();
		}
		
		protected function onReloadingtimer(event:TimerEvent):void {
			loadMore(reloadingList, null, true);
			reloadingList.length = 0;
		}
		
		protected function onItemLoaderSuccess(event:LoaderPoolEvent):void {
			var url:String = event.url;
			put(url, event.data[url]);
		}
		
		protected function onItemLoaderError(event:LoaderPoolEvent):void {
			if (event.error != "securityError") return;
			var url:String = event.url;
			delete pendingMap[url];
		}
		
		public function loadAsset(url:String, callback:Function = null):void {
			if (callback != null) registerSingleCallback(url, callback);
			if (hasData(url)) executeSingleCallback(url);
			else loadMore([url]);
		}
		
		protected function registerCallback(callback:Function):void {
			callbackList.push(callback);
		}
		
		protected function executeCallback():void {
			ObjectUtil.emptyObject(pendingMap);
			while (callbackList.length > 0) {
				var clbk:Function = callbackList.shift();
				clbk();
			}
		}
		
		protected function registerSingleCallback(key:String, callback:Function):void {
			if (!singleCallbacks[key]) singleCallbacks[key] = [];
			var list:Array = singleCallbacks[key];
			list.push(callback);
		}
		
		public function fill(data:Object):void {
			for (var i:String in data) put(i, data[i]);
		}
		
		public function put(key:String, item:*):void {
			if (item) {
				library[key] = item;
				delete pendingMap[key];
				executeSingleCallback(key);
			}
		}
		
		protected function executeSingleCallback(key:String):void {
			var list:Array = singleCallbacks[key];
			if (!list || !list.length) return;
			while (list.length > 0) {
				var clbk:Function = list.shift();
				clbk();
			}
			delete singleCallbacks[key];
		}
		
		public function loadMore(list:Array, callback:Function = null, download:Boolean = false):void {
			if (callback != null) registerCallback(callback);
			var missingList:Array = [];
			for (var i:int; i < list.length; i++) {
				var item:Object = list[i], 
					img:String;
				if (item is String) img = String(item);
				else img = list[i].image;
				if (img && !img.match(/^http/) && !hasData(img) && !pendingMap[img]) {
					missingList.push(img);
					pendingMap[img] = true;
				}
			}
			if (missingList.length > 0) {
				assetLoader.load(missingList, download);
			} else if (!assetLoader.loading) {
				dispatchEvent(new AssetLibraryEvent(AssetLibraryEvent.ON_NOTHING_TO_LOAD, { } ));
				executeCallback();
			}
		}
		
		public function hasData(url:String):Boolean {
			return !!library[url];
		}
		
		public function cancelAll():void {
			var cancelList:Array = [];
			for (var i:String in pendingMap) cancelList.push(i);
			cancelMore(cancelList);
		}
		
		public function cancelMore(assetList:Array):void {
			if (assetList == null || !assetList.length) return;
			for each (var url:String in assetList) {
				cancel(url);
			}
		}
		
		public function cancel(url:String):void {
			delete pendingMap[url];
			assetLoader.cancel(url);
		}
		
		public function clearLibrary():void {
			ObjectUtil.emptyObject(library);
		}
		
		public function destroy():void {
			clearLibrary();
			library = null;
			assetLoader.destroy();
			assetLoader = null;
			reloadingTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onReloadingtimer);
			reloadingTimer = null;
			pendingMap = null;
			callbackList.length = 0;
			callbackList = null;
			reloadingList.length = 0;
			reloadingList = null;
		}
		
	}

}