package eldhelm.util {
	import eldhelm.event.RpcEvent;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class RpcPool extends EventDispatcher {
		
		public var maxConnections:int = 2;
		private var rpcs:Array = [];
		private var rpcQueue:Array;
		private var completeCnt:int = 0;
		private var completeCallback:Function;
		private var failCnt:int = 0;
		private var failCallback:Function;
		private var successCallback:Function;
		public var autoDestroy:Boolean = false;
		
		public static function execute(config:Object):void {
			config.autoDestroy = true;
			new RpcPool(config).request();
		}
		
		public function RpcPool(config:Object) {
			if (config) {
				if (config.autoDestroy) autoDestroy = config.autoDestroy;
				if (config.complete) {
					completeCallback = config.complete;
					addEventListener(RpcEvent.ON_COMPLETE, config.complete, false, 0, true);
				}
				if (config.fail) {
					failCallback = config.fail;
					addEventListener(RpcEvent.ON_FAIL, config.fail, false, 0, true);
				}
				if (config.success) {
					successCallback = config.success;
					addEventListener(RpcEvent.ON_SUCCESS, config.success, false, 0, true);
				}
				if (config.rpcs) setRpcList(config.rpcs);
			}
		}
		
		public function get length():int {
			return rpcs.length;
		}
		
		public function setRpcList(list:Array):void {
			for (var i:int = 0; i < list.length; i++) getRpc(list[i]);
		}
		
		public function getRpc(config:Object = null):Rpc {
			var rpc:Rpc = new Rpc(config);
			rpc.addEventListener(RpcEvent.ON_COMPLETE, onComplete);
			rpc.addEventListener(RpcEvent.ON_FAIL, onFail);
			//rpc.addEventListener(RpcEvent.ON_ERROR, onComplete);
			rpcs.push(rpc);
			return rpc;
		}
		
		private function onComplete(event:RpcEvent):void {
			completeCnt++;
			requestNext();
		}
		
		private function onFail(event:RpcEvent):void {
			failCnt++;
		}
		
		public function request():void {
			rpcQueue = rpcs.concat();
			for (var i:int = 0; i < maxConnections; i++) {
				if (!requestNext()) break;
			}
		}
		
		protected function requestNext():Boolean {
			var rpc:Rpc = rpcQueue.shift();
			if (rpc) {
				rpc.request(); 
				return true;
			} else if (completeCnt == length) {
				finishQueue();
			}
			return false;
		}
		
		protected function finishQueue():void {
			completeCnt = 0;
			var evParams:Object = {
				success: failCnt == 0
			};
			dispatchEvent(new RpcEvent(failCnt > 0 ? RpcEvent.ON_FAIL : RpcEvent.ON_SUCCESS, evParams ));
			dispatchEvent(new RpcEvent(RpcEvent.ON_COMPLETE, evParams ));
			if (autoDestroy) destroy();
		}
		
		public function destroy():void {
			if (completeCallback != null) {
				removeEventListener(RpcEvent.ON_COMPLETE, completeCallback);
				completeCallback = null;
			}
			if (failCallback != null) {
				removeEventListener(RpcEvent.ON_FAIL, failCallback);
				failCallback = null;
			}
			if (successCallback != null) {
				removeEventListener(RpcEvent.ON_SUCCESS, successCallback);
				successCallback = null;
			}
			for (var i:int = 0; i < rpcs.length; i++) {
				var rpc:Rpc = rpcs[i];
				rpc.removeEventListener(RpcEvent.ON_COMPLETE, onComplete);
				rpc.removeEventListener(RpcEvent.ON_FAIL, onFail);
				//rpc.removeEventListener(RpcEvent.ON_ERROR, onComplete);
				rpc.destroy();
			}
			rpcs.length = 0;
			rpcs = null;
			rpcQueue.length = 0;
			rpcQueue = null;
		}
		
	}

}