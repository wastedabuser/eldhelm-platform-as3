package eldhelm.network {
	import eldhelm.event.ConnectionEvent;
	import eldhelm.event.RpcEvent;
	import eldhelm.manager.AppManager;
	import eldhelm.util.ObjectUtil;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class Rpc extends EventDispatcher {
		
		protected static var globalRpcCounter:int;
		
		public var callbackParams:Object;
		public var action:String;
		public var params:Object;
		public var autoDestroy:Boolean;
		public var connection:Connection = AppManager.connection;
		
		protected var rpcId:int;
		protected var completeCallback:Function;
		protected var successCallback:Function;
		protected var failCallback:Function;
		protected var reqParams:Object;
		
		public static function execute(config:Object):void {
			config.autoDestroy = true;
			new Rpc(config).request();
		}
		
		public function Rpc(config:Object = null) {
			rpcId = ++globalRpcCounter;
			if (config) {
				if (config.action) action = config.action;
				if (config.procedure) procedure = config.procedure;
				if (config.params) params = config.params;
				if (config.autoDestroy) autoDestroy = config.autoDestroy;
				if (config.callbackParams) callbackParams = config.callbackParams;
				if (config.complete) {
					completeCallback = config.complete;
					addEventListener(RpcEvent.ON_COMPLETE, completeCallback);
				}
				if (config.success) {
					successCallback = config.success;
					addEventListener(RpcEvent.ON_SUCCESS, successCallback);
				}
				if (config.fail) {
					failCallback = config.fail;
					addEventListener(RpcEvent.ON_FAIL, failCallback);
				}
				if (config.error) {
					trace("RPC error callback is deprecated!");
				}
			}
		}
		
		public function set procedure(str:String):void {
			action = str.replace(/\./, ":");
		}
		
		public function request(moreParams:Object = null):void {
			reqParams = moreParams;
			connection.addEventListener(ConnectionEvent.ON_RPC_RESPONSE, onReceive);
			connection.say( { action: action, data: reqParams || params }, { rpcId: rpcId });
		}
		
		protected function onReceive(event:ConnectionEvent):void {			
			var data:Object = event.params.data, 
				headers:Object = event.params.headers;
			
			if (headers.rpcId != rpcId) return;
			if (!data) data = { };
			
			var errs:Array = data.errors,
				suc:Boolean = data.success,
				evParams:Object = ObjectUtil.extend( { 
					data: data.data, 
					success: suc,
					errors: errs,
					flags: data.flags,
					unauthorized: errs && errs.length && errs[0] == "server_error_unauthorized_request"
				}, callbackParams);
			
			dispatchEvent(new RpcEvent(suc ? RpcEvent.ON_SUCCESS : RpcEvent.ON_FAIL, evParams));
			dispatchEvent(new RpcEvent(RpcEvent.ON_COMPLETE, evParams));
			
			cleanUp();
		}
		
		protected function cleanUp():void {
			if (autoDestroy) destroy();
			else removeEvents();
		}
		
		protected function removeEvents():void {
			if (!connection) return;
			connection.removeEventListener(ConnectionEvent.ON_RPC_RESPONSE, onReceive);
		}
		
		public function destroy():void {
			removeEvents();
			if (completeCallback != null) {
				removeEventListener(RpcEvent.ON_SUCCESS, completeCallback);
				completeCallback = null;
			}
			if (successCallback != null) {
				removeEventListener(RpcEvent.ON_SUCCESS, successCallback);
				successCallback = null;
			}
			if (failCallback != null) {
				removeEventListener(RpcEvent.ON_FAIL, failCallback);
				failCallback = null;
			}
			params = null;
			connection = null;
			callbackParams = null;
			reqParams = null;
		}
	}

}