package eldhelm.manager {
	import eldhelm.manager.AssetLibrary;
	import eldhelm.network.LoaderPoolImage;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ImageLibrary extends AssetLibrary {
		
		protected var _textureCache:Object = { };
		
		public function ImageLibrary() {
			assetLoader = new LoaderPoolImage( {
				success: onAllLoaderSuccess,
				itemSuccess: onItemLoaderSuccess,
				itemError: onItemLoaderError
			});
		}
		
		override public function put(key:String, item:*):void {
			if (item is BitmapData) {
				var bm:BitmapData = item as BitmapData;
				if (bm != null && bm.width > 0) {
					library[key] = item;
					delete pendingMap[key];
					executeSingleCallback(key);
				}
			}
		}
		
		public function getBitmapData(url:String):BitmapData {
			return library[url] is BitmapData ? BitmapData(library[url]).clone() : null;
		}
		
		public function getBitmapDataRef(url:String):BitmapData {
			return library[url] is BitmapData ? BitmapData(library[url]) : null;
		}
		
		public function clearTextureCache():void {
			for (var i:String in _textureCache) {
				if (!_textureCache[i]) continue;
				_textureCache[i].dispose();
				_textureCache[i] = null;
			}
		}
		
		override public function hasData(url:String):Boolean {
			return library[url] is BitmapData;
		}
		
		public function removeData(url:String):void {
			var bd:BitmapData = library[url];
			if (!bd) return;
			
			bd.dispose();
			delete library[url];
		}
		
		override public function destroy():void {
			clearTextureCache();
			_textureCache = null;
			super.destroy();
		}
		
	}

}