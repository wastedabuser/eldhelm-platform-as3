package eldhelm.util {
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class AlignUtil {
		
		public static function centerInside(obj:*, width:Number = NaN, height:Number = NaN):* {
			if (!isNaN(width)) obj.x = (width -  obj.width) / 2;
			if (!isNaN(height)) obj.y = (height - obj.height) / 2;
		}
	
	}

}