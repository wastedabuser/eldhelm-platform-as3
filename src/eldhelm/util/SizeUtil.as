package eldhelm.util {
	import eldhelm.manager.AppManager;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SizeUtil {
	
		/**
		 * Resizes an object so both with and height are at least as large as the specified ones.
		 * @param	obj
		 * @param	width
		 * @param	height
		 * @return
		 */
		public static function fit(obj:*, width:Number = NaN, height:Number = NaN):* {
			if (isNaN(width)) width = AppManager.stageWidth;
			if (isNaN(height)) height = AppManager.stageHeight;
			
			var ratio:Number = width / height;
			var ratio2:Number = obj.width / obj.height;
			if (ratio == ratio2) {
				obj.width = width;
				obj.height = height;
			} else if (ratio < ratio2) {
				obj.width = height / obj.height * obj.width;
				obj.height = height;
			} else {
				obj.height = width / obj.width * obj.height;
				obj.width = width;
			}
			return obj;
		}
		
		/**
		 * Resizes an object so both with and height are no larger than the specified ones.
		 * @param	obj
		 * @param	width
		 * @param	height
		 * @return
		 */
		public static function fitInside(obj:*, width:Number = NaN, height:Number = NaN):* {
			if (isNaN(width)) width = AppManager.stageWidth;
			if (isNaN(height)) height = AppManager.stageHeight;
			
			var sw:Number = height / obj.height * obj.width,
				sh:Number = width / obj.width * obj.height;
			if (sw <= width) {
				obj.width = sw;
				obj.height = height;
			} else if (sh <= height) {
				obj.height = sh;
				obj.width = width;
			} else {
				obj.width = width;
				obj.height = height;
			}
			return obj;
		}
		
	}

}