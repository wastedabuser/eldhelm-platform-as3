package eldhelm.air {
	import com.coltware.airxzip.ZipEntry;
	import com.coltware.airxzip.ZipEvent;
	import com.coltware.airxzip.ZipFileReader;
	import eldhelm.event.LoaderPoolEvent;
	import eldhelm.interfaces.ILoaderPool;
	import eldhelm.manager.AppManager;
	import eldhelm.manager.AssetChecker;
	import eldhelm.manager.MsgManager;
	import eldhelm.manager.ProgressManager;
	import eldhelm.util.CallbackManager;
	import eldhelm.util.ObjectUtil;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class AssetCheckerAir extends AssetChecker implements ILoaderPool {
		
		public var obbPath:String;
		
		protected var manifest:Array;
		protected var callbackManager:CallbackManager;
		protected var _cacher:AssetLibraryCache;
		
		protected var obbFiles:Array;
		protected var obbFilesLn:int;
		protected var obbProcessed:int;
		protected var reader:ZipFileReader;
		protected var cacheDir:File;
		protected var eventDispatcher:EventDispatcher;
		
		public function AssetCheckerAir(config) {
			super();
			ObjectUtil.applyConfig(this, config);
			callbackManager = new CallbackManager(config);
		}
		
		override public function check(callback:Function):void {
			callbackManager.one("doneCheck", callback);
			
			ProgressManager.start(AppManager.langManager.text("progress_window_set_up"));
			checkObbPackages();
		}
		
		protected function checkObbPackages():void {
			if (!obbPath)
				throw("Please provide obb path");
				
			var obbDir:File = new File(obbPath);
			if (!obbDir.exists) {
				trace("[Asset checker] Path " + obbDir.nativePath + " does not exist!");
				checkWithManifest();
				return;
			}
			
			ProgressManager.start(AppManager.langManager.text("progress_window_install"), this);
			obbProcessed = 0;
			reader = new ZipFileReader;
			reader.addEventListener(ZipEvent.ZIP_DATA_UNCOMPRESS, onEntryUzniped);
			reader.addEventListener(ZipEvent.ZIP_DATA_UNCOMPRESS_ALL, onObbReady);
			obbFiles = obbDir.getDirectoryListing();
			obbFilesLn = obbFiles.length;
			cacheDir = new File(AppManager.cachePath);
			processNextObb();
		}
		
		protected function processNextObb():void {
			if (obbFiles.length) {
				processObb(obbFiles.shift());
				return;
			}
			
			reader.removeEventListener(ZipEvent.ZIP_DATA_UNCOMPRESS, onEntryUzniped);
			reader.removeEventListener(ZipEvent.ZIP_DATA_UNCOMPRESS_ALL, onObbReady);
			//dispatchEvent(new LoaderPoolEvent(LoaderPoolEvent.ON_SUCCESS));
			ProgressManager.finish();
			
			checkWithManifest();
		}
		
		protected var extReg:RegExp = /\.obb$/i;
		protected var obbName:String;
		protected var unzipCount:int;
		protected var unzipTotalCount:int;
		protected function processObb(obb:File):void {
			trace("[Asset checker] Checking: " + obb.nativePath);
			if (obb.isDirectory || !extReg.test(obb.nativePath)) {
				obbProcessed++;
				processNextObb();
				return;
			}
			
			var ch:Array = obb.nativePath.split(File.separator);
			obbName = ch[ch.length - 1];
			
			if (AppManager.storageManager.getVar(obbName)) {
				trace("[Asset checker] The following obb is already processed: " + obb.nativePath);
				obbProcessed++;
				processNextObb();
				return;
			}
			
			unzipCount = unzipTotalCount = 0;
			reader.open(obb);
			var fileList:Array = reader.getEntries();
			for each (var entry:ZipEntry in fileList){
				if (entry.isDirectory()){
					var dir:File = cacheDir.resolvePath(entry.getFilename());
					trace("[Asset checker] Create directory " + dir.nativePath);
					dir.createDirectory();
				} else {
					unzipTotalCount++;
					reader.unzipAsync(entry);
				}
			}
		}
		
		protected function onEntryUzniped(event:ZipEvent):void {
			var unzippedBytes:ByteArray = event.data,
				unziped:File = cacheDir.resolvePath(event.entry.getFilename());
				
			trace("[Asset checker] Extracting: " + unziped.nativePath);
			var fs:FileStream = new FileStream();
			fs.open(unziped, FileMode.WRITE);
			fs.writeBytes(unzippedBytes);
			fs.close();
			
			unzipCount++;
			dispatchEvent(new LoaderPoolEvent(LoaderPoolEvent.ON_PROGRESS, {
				progress: (100 / obbFilesLn) * (obbProcessed + unzipCount / unzipTotalCount)
			}));
		}
		
		protected function onObbReady(event:ZipEvent):void {
			reader.close();
			AppManager.storageManager.setVar(obbName, true);
			obbProcessed++;
			processNextObb();
		}
		
		protected function checkWithManifest():void {
			trace("[Asset checker] Checking asset manifest");
			AppManager.dataRepository.loadFile("assets-manifest", "/assets-manifest.json", onManifestLoaded);
		}
		
		protected function onManifestLoaded():void {
			manifest = AppManager.dataRepository.getData("assets-manifest") as Array;
			if (!manifest) {
				trace("[Asset checker] There isnt asset manifest available");
				done();
				return;
			}
			
			var list:Array = [],
				okCnt:int,
				modifiedCnt:int,
				missingCnt:int;
			for (var i:int = 0, l:int = manifest.length; i < l; i++) {
				var entry:Array = manifest[i],
					url:String = entry[0],
					size:int = entry[1];
					
				var fl:File = new File(AppManager.cachePath + url);
				if (fl.exists && fl.size == size) {
					//trace("[Asset checker] Asset " + url + " OK");
					okCnt++;
					continue;
				}
				
				if (!fl.exists) {
					//trace("[Asset checker] Asset " + url + " MISSING");
					missingCnt++;
				} else {
					//trace("[Asset checker] Asset " + url + " MODIFIED");
					modifiedCnt++;
				}
				
				list.push(url);
			}
			trace("[Asset checker] Assets ok " + okCnt + "; modified " + modifiedCnt + "; missing " + missingCnt + ";");
			
			if (list.length) {
				ProgressManager.start(AppManager.langManager.text("progress_window_downloading"), cacher.binaryLoader);
				cacher.load(list);
			} else
				done();
		}
		
		protected function get cacher():AssetLibraryCache {
			return _cacher ||= new AssetLibraryCache({
				events: {
					success: onCacheSucess
				}
			});
		}
		
		protected function onCacheSucess():void {
			ProgressManager.finish();
			
			done();
		}
		
		protected function done():void {
			ProgressManager.finish();
			trace("[Asset checker] Done");
			
			callbackManager.trigger("doneCheck");
		}
		
	}

}