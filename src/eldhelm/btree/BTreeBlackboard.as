package eldhelm.btree {
	import eldhelm.btree.iface.IBTreeActor;
	import eldhelm.btree.iface.IBTreeSubject;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeBlackboard {
		
		private static var resourceRepo:Object = {};
		
		public static function addResourceList(list:*):void {
			for each (var o:Object in list)
				resourceRepo[o.id] = o;
		}
		
		public static function getResourceById(id:String):Object {
			return resourceRepo[id];
		}
		
		public static function getActorById(id:String):IBTreeActor {
			return resourceRepo[id] as IBTreeActor;
		}
		
		public static function getSubjectById(id:String):IBTreeSubject {
			if (!resourceRepo[id]) resourceRepo[id] = new BTreeValue(id);
			return resourceRepo[id] as IBTreeSubject;
		}
		
		public static function add(obj:Object):void {
			resourceRepo[obj.id] = obj;
		}
		
		public static function removeList(list:*):void {
			for each (var o:Object in list)
				remove(o);
		}
		
		public static function remove(obj:Object):void {
			removeById(obj.id);
		}
		
		public static function removeById(id:String):void {
			delete resourceRepo[id];
		}
		
		public static function clear():void {
			var list:Vector.<String> = new Vector.<String>;
			for (var i:String in resourceRepo) list.push(i);
			for each (i in list) removeById(i);
		}
		
	}

}