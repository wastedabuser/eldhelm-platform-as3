package eldhelm.network {
	import eldhelm.manager.AppManager;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ImageLoaderPool extends LoaderPool {
		
		public function ImageLoaderPool(config:Object = null) {
			super(config);
			createLoaders();
		}
		
		protected function createLoaders():void {
			for (var i:int = 0; i < AppManager.cdnMaxConnections; i++) {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
				loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus, false, 0, true);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError, false, 0, true);
				loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
				loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, onError, false, 0, true);
				loaders.push(loader);
			}
		}
		
		override protected function onComplete(event:Event):void {
			var loader:Loader = event.target.loader;
			delete tempProgress[event.target];
			var url:String = event.target.url;
			try {
				var image:Bitmap = event.target.content;
				data[urlLookUp[url]] = image.bitmapData;
				super.onComplete(event);
			} catch (e:Error) {
				//MsgManager.warn(e.name + ":" + e.message + " from " + url);
				if (e.name.match(/securityerror/i)) dispatchError(url, "securityError");
				trace(e);
			}
			skip(loader);
		}
		
		protected function onIoError(event:IOErrorEvent):void {
			trace(event);
			skip(event.target.loader);
		}
		
		protected function onSecurityError(event:SecurityErrorEvent):void {
			trace(event);
			dispatchError(event.target.url, "securityError");
			skip(event.target.loader);
		}
		
		protected function onError(event:ErrorEvent):void {
			trace(event);
			skip(event.target.loader);
		}
		
		protected function skip(loader:Loader):void {
			loader.unload();
			loadedCount++;
			loadNext(loader);
		}
		
		public function load(list:Array = null):void {
			if (list != null) pend(list);
			if (!loading) {
				loading = true;
				loadedCount = 0;
				for (var i:int = 0; i < loaders.length; i++) {
					if (!loadNext(loaders[i])) break;
				}
			}
		}
		
		public function loadNext(loader:Loader):Boolean {
			var url:String = realUrls.shift();
			if (url != null) {
				try {
					loader.load(new URLRequest(url));
				} catch (e:Error) {
					trace(e);
					skip(loader);
				}
				return true;
			} else if (loadedCount >= urlCount) {
				onAllComplete();
			}
			return false;
		}
		
		override public function destroy():void {
			for (var i:int = 0; i < loaders.length; i++) {
				var loader:Loader = loaders[i];
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				loader.contentLoaderInfo.removeEventListener(ErrorEvent.ERROR, onError);
			}
			super.destroy();
		}
		
	}

}