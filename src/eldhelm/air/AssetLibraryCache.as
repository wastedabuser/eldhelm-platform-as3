package eldhelm.air {
	import eldhelm.config.Files;
	import eldhelm.event.LoaderPoolEvent;
	import eldhelm.manager.AppManager;
	import eldhelm.network.LoaderPoolFile;
	import eldhelm.util.CallbackManager;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class AssetLibraryCache {
		
		public var callbackManager:CallbackManager;
		public var binaryLoader:LoaderPoolFile;
		
		public function AssetLibraryCache(config:Object) {
			binaryLoader = new LoaderPoolFile( {
				urlPrefix: "/obb",
				dataFormat: URLLoaderDataFormat.BINARY,
				success: onAllFileLoaderSuccess,
				itemSuccess: onFileItemLoaderSuccess,
				itemError: onFileItemLoaderError
			});
			callbackManager = new CallbackManager(config);
		}
		
		protected function onAllFileLoaderSuccess(event:LoaderPoolEvent):void {
			callbackManager.trigger("success");
		}
		
		protected function onFileItemLoaderSuccess(event:LoaderPoolEvent):void {
			var url:String = event.url;
			cacheFile(url, event.data[url]);
		}
		
		protected function onFileItemLoaderError(event:LoaderPoolEvent):void {
			if (event.error != "securityError") return;
			
		}
		
		protected function cacheFile(url:String, ba:ByteArray):void {
			if (!ba) return;
			
			var fl:File = new File(Files.cachePath + File.separator + url),
				path:String = fl.nativePath.replace(/[^\\\/]+$/, ''),
				dir:File = new File(path);
			dir.createDirectory();
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(fl, FileMode.WRITE);
			//fileStream.truncate();
			fileStream.writeBytes(ba);
			fileStream.close();
			
			trace("Caching file: " + fl.nativePath);
		}
		
		public function load(list:Array):void {
			binaryLoader.load(list, true);
		}
		
		public function destroy():void {
			binaryLoader.destroy();
			binaryLoader = null;
		}
		
	}

}