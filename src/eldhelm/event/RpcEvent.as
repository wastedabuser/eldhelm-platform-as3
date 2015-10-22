package eldhelm.event {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class RpcEvent extends Event {
		
		public static const ON_COMPLETE:String = "onRpcComplete";
		public static const ON_SUCCESS:String = "onRpcSuccess";
		public static const ON_FAIL:String = "onRpcFail";
		public static const ON_DROP:String = "onRpcDrop";
		public static const ON_ERROR:String = "onRpcError";
		
		public var params:Object;
		public var data:*;
		public var success:Boolean;
		public var errors:Array;
		public var flags:Object;
		
		public function RpcEvent(type:String, params:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this.params = params;
			if (params) {
				if (params.data) data = params.data;
				if (params.success) success = params.success;
				if (params.errors) errors = params.errors;
				if (params.flags) flags = params.flags;
			}
		} 
		
		public override function clone():Event { 
			return new RpcEvent(type, params, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("RpcEvent", "params", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}