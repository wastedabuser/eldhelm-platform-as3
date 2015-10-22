package eldhelm.embed {
	import eldhelm.asset.ImageResources;
	import eldhelm.manager.ImageLibrary;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ImageLibraryEmbedded extends ImageLibrary {
		
		public function ImageLibraryEmbedded() {
			super();
			
		}
		
		override public function getBitmapData(url:String):BitmapData {
			var cls:Class = ImageResources.assetMap[url];
			if (cls != null) return Bitmap(new cls).bitmapData;
			return super.getBitmapData(url);
		}
		
		override public function getBitmapDataRef(url:String):BitmapData {
			var cls:Class = ImageResources.assetMap[url];
			if (cls != null) return library[url] ||= Bitmap(new cls).bitmapData;
			return super.getBitmapDataRef(url);
		}
		
		override public function hasData(url:String):Boolean {
			if (ImageResources.assetMap[url]) return true;
			return super.hasData(url);
		}
		
	}

}