package eldhelm.util {
	import eldhelm.manager.AppManager;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class EldLater {
		
		private var enabled:Boolean;
		private var callbacksLn:int = 0;
		private var callbacks:Dictionary = new Dictionary;
		private var pausedCallbacks:Dictionary = new Dictionary;
		private var executed:Vector.<Function> = new Vector.<Function>;
		private var completed:Vector.<Function> = new Vector.<Function>;
		
		public function EldLater():void {
			
		}
		
		public function has(callback:Function):Boolean {
			return callbacks[callback] is Function;
		}
		
		public function onNextFrame(callback:Function, params:Array = null):void {
			callAfterFrames(1, callback, params);
		}
		
		public function callAfterInterval(seconds:Number, callback:Function, params:Array = null):void {
			callAfterFrames(Math.round(AppManager.frameRate * seconds), callback, params);
		}	
		
		public function callAfterFrames(frame:int, callback:Function, params:Array = null):void {
			if (callbacks[callback]) return;
			
			callbacks[callback] = [1, frame, callback, params ];
			callbacksLn++;
		}	
		
		public function remove(func:Function):void {
			if (!callbacks[func]) return;
			
			delete callbacks[func];
			callbacksLn--;
		}
		
		private function onEnterFrame(e:Event):void {
			if (callbacksLn == 0) return;
			
			for (var func:Function in callbacks)
				executed.push(func);
			
			var vLen:int = executed.length;
			for (var vi:int = 0; vi < vLen; vi++) {
				func = executed[vi];
				if (!callbacks[func]) continue;
				var arr:Array = callbacks[func];
				if (arr[0] < arr[1]) {
					arr[0]++;
					continue;
				}
				callCalback(arr[2], arr[3]);
				completed.push(func);
			}
			executed.length = 0;
			
			if (completed.length > 0) {
				vLen = completed.length;
				for (vi = 0; vi < vLen; vi++) {
					func = completed[vi];
					if (!callbacks[func]) continue;
					
					delete callbacks[func];
					callbacksLn--;
				}
				completed.length = 0;
			}
		}
		
		public function enable():void {
			if (enabled) return;
			AppManager.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			enabled = true;
		}
		
		public function disable():void {
			if (!enabled) return;
			AppManager.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			enabled = false;
		}
		
		private function callCalback(callback:Function, callbackParams:Array = null):void {
			if (callback == null) return;
			
			if (callbackParams) callback.apply(null, callbackParams);
			else callback.call();
		}
		
		private var tempList:Vector.<Function> = new Vector.<Function>;
		public function pause():void {
			for (var func:Function in callbacks) {
				pausedCallbacks[func] = callbacks[func];
				tempList.push(func);
			}
			for each (func in tempList)
				delete callbacks[func];
		}
		
		public function resume():void {
			for (var func:Function in pausedCallbacks) {
				callbacks[func] = pausedCallbacks[func];
				tempList.push(func);
			}
			for each (func in tempList)
				delete pausedCallbacks[func];
		}
		
		public function removeAllPaused():void {
			for (var func:Function in pausedCallbacks) {
				tempList.push(func);
			}
			for each (func in tempList)
				delete pausedCallbacks[func];
		}
		
		public function removeAll():void {
			for (var func:Function in callbacks) {
				tempList.push(func);
			}
			for each (func in tempList)
				delete callbacks[func];
		}

	
	}

}