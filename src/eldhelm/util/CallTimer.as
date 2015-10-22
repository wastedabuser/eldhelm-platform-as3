package eldhelm.util {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class CallTimer {
		
		private static var timer:EldTimer = new EldTimer;
		
		//[Inline]
		public static function callOnFrame(frame:int, callback:Function, params:Array = null):void {
			timer.callOnFrame(frame, callback, params);
		}
		
		//[Inline]
		public static function callEveryFrame(callback:Function, params:Array = null):void {
			timer.callEveryFrame(callback, params);
		}
		
		//[Inline]
		public static function callOnInterval(seconds:Number, callback:Function, params:Array = null):int {
			return timer.callOnInterval(seconds, callback, params);
		}
		
		//[Inline]
		public static function remove(func:Function):void {
			timer.remove(func);
		}
		
		//[Inline]
		public static function invalidateFrame():void {
			timer.invalidateFrame();
		}
		
		//[Inline]
		public static function enable():void {
			timer.enable();
		}
		
		//[Inline]
		public static function disable():void {
			timer.disable();
		}
		
		//[Inline]
		public static function pause():void {
			timer.pause();
		}
		
		//[Inline]
		public static function resume():void {
			timer.resume();
		}
		
		//[Inline]
		public static function removeAllPaused():void {
			timer.removeAllPaused();
		}
		
		//[Inline]
		public static function removeAll():void {
			timer.removeAll();
		}
		
		//[Inline]
		public static function get currentTick():int {
			return timer.currentTick;
		}
		
	}

}