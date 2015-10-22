package eldhelm.event {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class RequestEvent extends Event {
		
		public static const ON_SUCCESS:String = "onRequestSuccess";
		public static const ON_FAIL:String = "onRequestFail";
		
		public var params:Object;
		public var content:String;
		public var data:Object;
		
		public function RequestEvent(type:String, params:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this.params = params;
			if (params) {
				if (params.content) content = params.content;
				if (params.data) data = params.data;
			}
		} 
		
		public override function clone():Event { 
			return new RequestEvent(type, params, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("RequestEvent", "params", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}