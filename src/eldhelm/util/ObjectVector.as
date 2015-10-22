package eldhelm.util {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ObjectVector {
		
		public var items:Array = [];
		protected var itemConstructor:Function;
		protected var itemClass:Class;
		protected var itemConfig:Object;
		protected var itemConfigParam:String;
		protected var itemsAfter:Array;
		
		/**
		 * Creates a list of Classes from a list of Objects
		 * @param	config
		 * itemClass
		 * itemConfig
		 * itemConfigParam
		 * itemsAfter
		 * vectorData
		 * @return
		 */
		public static function create(config:Object):Array {
			return new ObjectVector(config).items;
		}
		
		public function ObjectVector(config:Object = null) {
			if (config) {
				if (config.itemConstructor) itemConstructor = config.itemConstructor;
				if (config.itemClass) itemClass = config.itemClass;
				if (config.itemConfig) itemConfig = config.itemConfig;
				if (config.itemConfigParam) itemConfigParam = config.itemConfigParam;
				if (config.itemsAfter) itemsAfter = config.itemsAfter;
				if (config.vectorData) fill(config.vectorData);
			}
		}
		
		public function fill(data:Array):ObjectVector {
			removeAll();
			if (data != null) {
				for (var i:int = 0; i < data.length; i++) {
					var config:Object;
					if (itemConfigParam) {
						config = {};
						config[itemConfigParam] = data[i];
					} else 
						config = data[i];
						
					if (itemConfig) config = ObjectUtil.extend({}, config, itemConfig);
					var item:Object;
					if (itemConstructor is Function) item = itemConstructor(config);
					else item = new itemClass(config);
					add(item);
				}
			}
			if (itemsAfter) {
				for (i = 0; i < itemsAfter.length; i++) {
					add(itemsAfter[i]);	
				}
			}
			return this;
		}
		
		public function add(item:Object):void {
			items.push(item);
		}
		
		public function removeAll():void {
			items.length = 0;
		}
		
		public function destroy():void {
			removeAll();
			items = null;
			if (itemsAfter != null) {
				itemsAfter.length = 0;
				itemsAfter = null;
			}
			itemClass = null;
			itemConfig = null;
		}
		
	}

}