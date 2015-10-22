package eldhelm.util {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class CallLater {
		
		private static var later:EldLater = new EldLater;
		
		//[Inline]
		public static function has(callback:Function):Boolean {
			return later.has(callback);
		}
		
		//[Inline]
		public static function onNextFrame(callback:Function, params:Array = null):void {
			later.onNextFrame(callback, params);
		}
		
		//[Inline]
		public static function callAfterInterval(seconds:Number, callback:Function, params:Array = null):void {
			later.callAfterInterval(seconds, callback, params);
		}	
		
		//[Inline]
		public static function callAfterFrames(frame:int, callback:Function, params:Array = null):void {
			later.callAfterFrames(frame, callback, params);
		}	
		
		[Inline]
		public static function remove(func:Function):void {
			later.remove(func);
		}
		
		//[Inline]
		public static function enable():void {
			later.enable();
		}
		
		//[Inline]
		public static function disable():void {
			later.disable();
		}
		
		//[Inline]
		public static function pause():void {
			later.pause();
		}
		
		//[Inline]
		public static function resume():void {
			later.resume();
		}
		
		//[Inline]
		public static function removeAllPaused():void {
			later.removeAllPaused();
		}
		
		//[Inline]
		public static function removeAll():void {
			later.removeAll();
		}
		
	}

}