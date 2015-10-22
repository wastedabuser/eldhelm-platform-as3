package eldhelm.event {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ConnectionEvent extends Event {
		
		public static const ON_CONNECT:String = "onConnectionConnect";
		public static const ON_CONNECTED:String = "onConnectionConnected";
		public static const ON_DISCONNECTED:String = "onConnectionDisconnected";
		public static const ON_ERROR:String = "onConnectionError";
		public static const ON_TIMEOUT:String = "onConnectionTimeout";		
		public static const ON_SERVER_UNREACHABLE:String = "onServerUnreachable";
		
		public static const ON_SESSION_OPENED:String = "onSessionOpened";
		public static const ON_SESSION_CLOSED:String = "onSessionClossed";
		public static const ON_SESSION_RENEWED:String = "onSessionRenewed";
		public static const ON_SESSION_DENIED:String = "onSessionDenied";
		
		public static const ON_RPC_RESPONSE:String = "onRpcResponse";
		public static const ON_CONTENT_VERSION:String = "onContentVersion";
		
		public var params:Object;
		
		public function ConnectionEvent(type:String, $params:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			params = $params;
		} 
		
		public override function clone():Event { 
			return new ConnectionEvent(type, params, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ConnectionEvent", "params", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}