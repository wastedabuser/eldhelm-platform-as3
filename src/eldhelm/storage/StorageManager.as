package eldhelm.storage {
	import flash.net.SharedObject;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class StorageManager {
		
		private var ns:String;
		public function StorageManager($ns:String = "default") {
			ns = $ns;
		}
		
		public function hasVar(name:String):Boolean {
			return typeof storage[name] != "undefined";
		}
		
		public function setVar(name:String, value:*):* {
			return storage[name] = value;
		}
		
		public function getVar(name:String):* {
			return storage[name];
		}
		
		public function removeVar(name:String):void {
			delete storage[name];
		}
		
		public function setVarUnlessDefined(name:String, value:*):* {
			if (!hasVar(name)) setVar(name, value);
			return getVar(name);
		}
		
		public function setKeyValue(obj:Object):void {
			for (var i:String in obj) setVar(i, obj[i]);
		}
		
		public function removeList(list:Array):void {
			for each (var i:String in list) removeVar(i);
		}
		
		private function get storage():Object {
			var localData:SharedObject = SharedObject.getLocal(ns);
			return localData.data;
		}
		
	}

}