package eldhelm.designer {
	import eldhelm.util.ObjectUtil;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class EldDesigner {
		
		/**
		 * Returns definition of the first node matching the specified type. The search is recursive.
		 * @param	data
		 * @param	type
		 * @return
		 */
		public static function nodesByType(data:Object, type:String, deep:Boolean = true):Array {
			var list:Array = [];
			if (!data || !data.children) return list;
			
			for each (var obj:Object in data.children) {
				if (obj.type == type) {
					list.push(obj);
				} else if (deep) {
					var sList:Array = nodesByType(obj, type);
					list.push.apply(null, sList);
				}
			}
			return list;
		}
		
		public static function firstNodeByType(data:Object, type:String):Object {
			if (!data || !data.children) return null;
			
			for each (var obj:Object in data.children) {
				if (obj.type == type) {
					return obj;
				} else {
					var ref:Object = firstNodeByType(obj, type);
					if (ref) return ref;
				}
			}
			
			return null;
		}
		
		/**
		 * Returns definition of the first node matching the specified property key and value. The search is recursive.
		 * @param	data
		 * @param	key
		 * @param	value might be Regexp or String
		 * @return
		 */
		public static function findNode(data:Object, key:String, value:*):Object {
			if (!data || !data.children) return null;
			
			for each (var obj:Object in data.children) {
				var mtch:Boolean;
				if (value is String) mtch = obj[key] == value;
				else if (value is RegExp) mtch = value.test(obj[key]);
				if (mtch) {
					return obj;
				} else {
					var ref:Object = findNode(obj, key, value);
					if (ref) return ref;
				}
			}
			
			return null;
		}
		
		public static function constructObjectByType(data:Object, type:String, cls:Class = null, beforeConstruct:* = null, deep:Boolean = true):Array {
			var list:Array = [];
			if (!data || !data.children) return list;
			
			for each (var obj:Object in data.children) {
				if (obj.type == type) {
					var co:Object = constructObject(obj, cls, beforeConstruct);
					if (co) list.push(co);
				} else if (deep) {
					var sList:Array = constructObjectByType(obj, type, cls, beforeConstruct);
					list.push.apply(null, sList);
				}
			}
			return list;
		}
		
		public static function findAndConstruct(data:Object, key:String, value:*, cls:Class = null, beforeConstruct:* = null):Object {
			if (!data || !data.children) return null;
			
			for each (var obj:Object in data.children) {
				var mtch:Boolean;
				if (value is String) mtch = obj[key] == value;
				else if (value is RegExp) mtch = value.test(obj[key]);
				if (mtch) {
					return constructObject(obj, cls, beforeConstruct);
				} else {
					var ref:Object = findAndConstruct(obj, key, value, cls, beforeConstruct);
					if (ref) return ref;
				}
			}
			
			return null;
		}
		
		public static function constructObject(obj:Object, cls:Class = null, beforeConstruct:* = null):Object {
			var constructorObj:Object;
			if (beforeConstruct is Function) constructorObj = beforeConstruct(obj);
			else if (beforeConstruct is Object) constructorObj = merge(obj, beforeConstruct);
			else constructorObj = obj;
			
			if (!constructorObj) return null;
			
			var rClass:Class;
			if (constructorObj.properties && constructorObj.properties['class']) 
				rClass = getDefinitionByName(constructorObj.properties['class']) as Class;
			else rClass = cls;
			
			if (!rClass) return obj;
			return new rClass(constructorObj);
		}
		
		public static function extend(def:Object, ...rest:Array):Object {
			return extendList(def, rest);
		}
		
		[Inline]
		public static function extendList(def:Object, list:Array):Object {
			for each (var o:Object in list) {
				if (!o) continue;
				if (o.properties) ObjectUtil.extend(def.properties, o.properties);
				if (o.children) def.children = def.children.concat(o.children);
				if (o.files) def.files = def.files.concat(o.files);
			}
			return def;
		}
		
		public static function merge(...rest:Array):Object {
			var obj:Object = ObjectUtil.extendList({}, rest);
			obj.properties = {};
			obj.children = [];
			obj.files = [];
			return extendList(obj, rest);
		}
		
	}

}