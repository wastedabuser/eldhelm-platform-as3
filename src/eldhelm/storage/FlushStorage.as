package eldhelm.storage {
	import eldhelm.storage.StorageManager;
	import eldhelm.util.StringUtil;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FlushStorage {
		
		private var storageManager:StorageManager;
		private var ns:String;
		private var idPref:String;
		
		public function FlushStorage($ns:String = "default") {
			ns = $ns;
			storageManager = new StorageManager(ns);
			storageManager.setVarUnlessDefined("data", []);
			idPref = StringUtil.randomString(10);
		}
		
		public function get storage():Array {
			return storageManager.getVar("data");
		}
		
		private static var _id:int = 1;
		private function get nextID():String {
			return idPref + (_id++);
		}
		
		public function push(record:Array):String {
			var id:String = nextID;
			record.unshift(id);
			storage.push(record);
			return id;
		}
		
		public function export():Array {
			if (!storage.length) return null;
			return storage.concat();
		}
		
		public function flush(list:Array):void {
			var ids:Object = { };
			for (var i:int = 0, l:int = list.length; i < l; i++) {
				ids[list[i]] = true;
			}
			
			var arr:Array = storage,
				arr2:Array = [];
			l = arr.length;
			for (i = 0; i < l; i++) {
				var rec:Array = arr[i];
				if (!ids[rec[0]]) arr2.push(rec);
			}
			
			storageManager.setVar("data", arr2);
		}
	
	}

}