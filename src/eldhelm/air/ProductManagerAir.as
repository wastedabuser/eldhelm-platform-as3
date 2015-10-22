package eldhelm.air {
	import eldhelm.manager.AppManager;
	import eldhelm.manager.ProductManager;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ProductManagerAir extends ProductManager {
		
		public function ProductManagerAir(config:Object = null) {
			super(config);
		}
		
		override public function get productID():String {
			if (_productID) return _productID;
			
			if (AppManager.iniPath) _productID = readProductIdFromFile();
			trace("[Product Util] " + _productID);
			
			if (!_productID) {
				_productID = AppManager.storageManager.getVar("productID") || generateProductID();
				AppManager.storageManager.setVar("productID", _productID);
				if (AppManager.iniPath) saveProductIdToFile(_productID);
				callbackManager.execute("generate", [_productID]);
			}
			
			return _productID;
		}
		
		private function get productIdFilePath():File {
			return new File(AppManager.iniPath);
		}
		
		private function get productIdFile():File {
			return new File(AppManager.iniPath + File.separator + "product.ini");
		}
		
		public function readProductIdFromFile():String {
			var fl:File = productIdFile;
			if (!fl.exists) return null;
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(fl, FileMode.READ);
			var prodId:String = fileStream.readUTF();
			fileStream.close();
			return prodId;
		}
		
		public function saveProductIdToFile(prodId:String):void {
			var dr:File = productIdFilePath;
			dr.createDirectory();
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(productIdFile, FileMode.WRITE);
			fileStream.writeUTF(prodId);
			fileStream.close();
		}
		
	}

}