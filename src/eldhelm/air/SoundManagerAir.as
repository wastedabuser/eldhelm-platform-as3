package eldhelm.air {
	import eldhelm.event.LoaderPoolEvent;
	import eldhelm.manager.AppManager;
	import eldhelm.manager.SoundManager;
	import eldhelm.util.ObjectUtil;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class SoundManagerAir extends SoundManager {
		
		protected var cache:AssetLibraryCache;
		
		public function SoundManagerAir() {
			super();
			assetLoader.dirPrefix = AppManager.cachePath;
			cache = new AssetLibraryCache({
				events: {
					success: onCacheSuccess
				}
			});
		}
		
		protected function onCacheSuccess():void {
			reloadingTimer.start();
		}
		
		override protected function onAllLoaderSuccess(event:LoaderPoolEvent):void {
			for (var i:String in pendingMap) reloadingList.push(i);
			if (reloadingList.length > 0) {
				trace(reloadingList.length + " sounds not available. Loading from server...");
				cache.load(reloadingList);
				ObjectUtil.emptyObject(pendingMap);
			} else 
				executeCallback();
		}
		
		override protected function onReloadingtimer(event:TimerEvent):void {
			loadMore(reloadingList);
			reloadingList.length = 0;
		}
		
		override public function destroy():void {
			cache.destroy();
			cache = null;
			super.destroy();
		}
		
	}

}