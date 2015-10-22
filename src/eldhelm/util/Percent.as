package eldhelm.util {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class Percent {
		
		public var value:Number;
		
		public function Percent(per:String) {
			if (per) value = stringToNumber(per);
		}
		
		public static function stringToNumber(str:String):Number {
			var m:Array = str.match(/^([\d\.]+)%$/);
			return Number(m[1]) / 100;
		}
		
	}

}
