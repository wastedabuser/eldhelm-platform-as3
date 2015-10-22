package eldhelm.util {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ObjectUtil {
		
		public static function extend(obj:Object, ... rest):Object {
			return extendList(obj, rest);
		}
		
		public static function extendList(obj:Object, rest:Array):Object {
			var obj2:Object;
			for (var i:int = 0, l:int = rest.length; i < l; i++) {
				obj2 = rest[i];
				if (obj2 != null && typeof obj2 == "object") {
					for (var z:String in obj2) obj[z] = obj2[z];
				}
			}
			return obj;
		}
		
		public static function applyConfig(obj:Object, config:Object):Object {
			if (!config) return obj;
			var i:String;
			for (i in config) {
				if (!obj.hasOwnProperty(i)) continue;
				if (obj[i] is Function) {
					obj[i](config[i]);
				} else if (obj[i] is Boolean) {
					obj[i] = Boolean(int(config[i])) || config[i] == "true";
				} else if (typeof obj[i]) {
					obj[i] = config[i];
				}
			}
			return obj;
		}
		
		public static function group(list:Array, prop:String = "id"):Array {
			var grouped:Object = { }, item:Object, key:String;
			for (var i:int = 0, l:int = list.length; i < l; i++) {
				item = list[i];
				key = item[prop];
				if (!grouped[key]) grouped[key] = [];
				grouped[key].push(item);
			}
			var newlist:Array = [];
			for (var z:String in grouped) newlist.push(grouped[z]);
			return newlist;
		}
		
		public static function mapProperty(list:Array, prop:String):Array {
			if (list == null) return [];
			return list.map(
				function(obj:Object, index:int, array:Array):String { 
					return obj[prop];
				} 
			);
		}
		
		public static function makeObject(list:*, prop:String, value:* = "", options:Object = null):Object {
			var obj:Object = { },
				skipNulls:Boolean = options != null && options.skipNulls;
			for (var i:int = 0, l:int = list.length; i < l; i++) {
				var it:Object = list[i];
				if (skipNulls && it[prop] == null) continue;
				if (value is Function) {
					obj[it[prop]] = value(it);
					continue;
				}
				obj[it[prop]] = value ? it[value] : it;
			}
			return obj;
		}
		
		public static function makeObject2(list:*, options:Object = null):Object {
			var obj:Object = { };
			if (!list || !list.length) return obj;
			
			for (var i:int = 0, l:int = list.length; i < l; i++) {
				obj[list[i]] = list[i];
			}
			return obj;
		}
		
		public static function makeArray(obj:Object):Array {
			var list:Array = [];
			for (var i:String in obj) list.push(obj[i]);
			return list;
		}
		
		private static var clearList:Vector.<Object> = new Vector.<Object>;
		public static function emptyObject(obj:Object):void {
			if (!obj) return;
			
			for (var k:Object in obj) {
				clearList.push(k);
			}
			for (var i:int = 0, l:int = clearList.length; i < l; i++) {
				delete obj[clearList[i]];
			}
			clearList.length = 0;
		}
		
	}

}