package eldhelm.event {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class LoaderPoolEvent extends Event {
		
		public static const ON_ITEM_SUCCESS:String = "onItemLoaderSuccess";
		public static const ON_ITEM_ERROR:String = "onItemLoaderError";
		public static const ON_SUCCESS:String = "onAllLoaderSuccess";
		public static const ON_PROGRESS:String = "onAllLoaderProgress";
		
		public var params:Object;
		public var data:Object;
		public var progress:Number;
		public var url:String;
		public var error:String;
		
		public function LoaderPoolEvent(type:String, params:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this.params = params;
			if (params) {
				if (params.data) data = params.data;
				if (params.progress) progress = params.progress;
				if (params.url) url = params.url;
				if (params.error) error = params.error;
			}
		} 
		
		public override function clone():Event { 
			return new LoaderPoolEvent(type, params, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("LoaderPoolEvent", "params", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}