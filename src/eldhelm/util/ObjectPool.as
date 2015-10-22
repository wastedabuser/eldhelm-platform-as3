package eldhelm.util {
	import eldhelm.interfaces.IEldPoolable;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ObjectPool {
		
		public static const BUSY:String = "busy";
		public static const FREE:String = "free";
		public var callbackManager:CallbackManager;
		
		public var itemClass:Class;
		private var items:Vector.<IEldPoolable> = new Vector.<IEldPoolable>;
		private var freeItems:Vector.<IEldPoolable> = new Vector.<IEldPoolable>;
		private var busyItems:Vector.<IEldPoolable> = new Vector.<IEldPoolable>;
		
		public function ObjectPool(config:Object = null) {
			if (config != null) {
				if (config.itemClass) itemClass = config.itemClass;
			}
			callbackManager = new CallbackManager(config);
		}
		
		public function createItem(config:Object = null):IEldPoolable {
			var item:IEldPoolable = new itemClass(config);
			item.objectPool = this;
			items.push(item);
			freeItems.push(item);
			return item;
		}
		
		public function getItem(config:Object = null):IEldPoolable {
			var item:IEldPoolable = freeItems.shift();
			if (!item || item == null) {
				item = new itemClass(config);
				item.objectPool = this;
				items.push(item);
			}
			item.getPoolObject(config);
			busyItems.push(item);
			if (busyItems.length == 1) callbackManager.execute(BUSY);
			
			return item;
		}
		
		public function freeItem(item:IEldPoolable):void {
			if (!(item is itemClass)) throw("The supplied item is not of the specified type: " + itemClass);
			
			var index:int = freeItems.indexOf(item);
			if (index >= 0) return;
			
			item.freePoolObject();
			freeItems.push(item);
			
			var busyIndex:int = busyItems.indexOf(item);
			if (busyIndex >= 0) busyItems.splice(busyIndex, 1);
			
			if (!busyItems.length) callbackManager.execute(FREE);
		}
		
		private static var freeList:Vector.<IEldPoolable> = new Vector.<IEldPoolable>;
		public function freeAll():void {
			var vLen:int = items.length;
			for (var vi:int = 0; vi < vLen; vi++) {
				freeList.push(items[vi]);
			}
			vLen = freeList.length;
			for (vi = 0; vi < vLen; vi++) {
				freeItem(freeList[vi]);
			}
			freeList.length = 0;
		}
		
		[Inline]
		final public function get busyLength():int {
			return items.length - freeLength;
		}
		
		[Inline]
		final public function get freeLength():int {
			return freeItems.length;
		}
		
		private static var callList:Vector.<IEldPoolable> = new Vector.<IEldPoolable>;
		public function call(method:String, args:Array = null):void {
			var vLen:int = busyItems.length;
			for (var vi:int = 0; vi < vLen; vi++) {
				callList.push(busyItems[vi]);
			}
			vLen = callList.length;
			for (vi = 0; vi < vLen; vi++) {
				callList[vi][method].apply(null, args);
			}
			callList.length = 0;
		}
		
		public function destroyAllItems():void {
			freeAll();
			for each (var item:IEldPoolable in items) {
				item.destroy();
				item.objectPool = null;
			}
			items.length = 0;
			freeItems.length = 0;
			busyItems.length = 0;
		}
		
		public function destroy():void {
			destroyAllItems();
			items = null;
			freeItems = null;
			busyItems = null;
			itemClass = null;
			callbackManager.destroy();
			callbackManager = null;
		}
		
	}

}