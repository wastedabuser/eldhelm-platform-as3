package eldhelm.util {
	import eldhelm.manager.AppManager;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class EldTimer {
		
		public var currentTick:int;
		
		private var enabled:Boolean;
		private var callbacksLn:int;
		private var callbacks:Dictionary = new Dictionary;
		private var callbackList:Vector.<Function> = new Vector.<Function>;
		private var executed:Vector.<Function> = new Vector.<Function>;
		private var pausedCallbacks:Dictionary = new Dictionary;
		
		public function EldTimer():void {
			
		}
		
		public function callOnFrame(frame:int, callback:Function, params:Array = null):void {
			if (callbacks[callback]) return;
			
			callbackList.push(callback);
			callbacks[callback] = [1, frame, callback, params];
			callbacksLn++;
		}
		
		public function callEveryFrame(callback:Function, params:Array = null):void {
			callOnFrame(1, callback, params);
		}
		
		public function callOnInterval(seconds:Number, callback:Function, params:Array = null):int {
			var frames:int = Math.round(AppManager.frameRate * seconds);
			callOnFrame(frames, callback, params);
			return frames;
		}
		
		public function remove(func:Function):void {
			if (!callbacks[func]) return;
			
			delete callbacks[func];
			delete pausedCallbacks[func];
			callbacksLn--;
			
			var index:int = callbackList.indexOf(func);
			if (index >= 0) callbackList.splice(index, 1);
		}
		
		private function onEnterFrame(e:Event):void {
			invalidateFrame();
			if (callbacksLn == 0) return;
			
			var func:Function;
			for (var i:int = 0, l:int = callbackList.length; i < l; i++) {
				func = callbackList[i];
				if (!pausedCallbacks[func]) executed.push(func);
			}
			
			if (!executed.length) return;
			l = executed.length;
			for (i = 0; i < l; i++) {
				func = executed[i];
				var arr:Array = callbacks[func];
				if (!arr) continue;
				if (arr[0] < arr[1]) {
					arr[0]++;
					continue;
				}
				arr[0] = 1;
				callCalback(arr[2], arr[3]);
			}
			executed.length = 0;
		}
		
		public function invalidateFrame():void {
			currentTick++;
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
		
		public function pause():void {
			for (var func:Function in callbacks) {
				pausedCallbacks[func] = callbacks[func];
			}
		}
		
		private var tempList:Vector.<Function> = new Vector.<Function>;
		public function resume():void {
			for (var func:Function in pausedCallbacks) {
				tempList.push(func);
			}
			for each (func in tempList){
				delete pausedCallbacks[func];
			}
			tempList.length = 0;
		}
		
		public function removeAllPaused():void {
			for (var func:Function in pausedCallbacks) {
				remove(func);
			}
			resume();
		}
		
		public function removeAll():void {
			for (var func:Function in callbacks) {
				tempList.push(func);
			}
			for each (func in tempList) {
				delete callbacks[func];
			}
			callbackList.length = 0;
		}

	
	}

}