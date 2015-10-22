package eldhelm.util {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class StringUtil {
		
		public static function ucFirst(str:String):String {
			var firstLetter:String = str.charAt(0).toUpperCase();
			var restWord:String = str.substr(1, str.length);
			return firstLetter + restWord;
		}
		
		public static function sprintf(str:String, ...more:Array):String {
			if (!str || str == null) return "";
			if (!more.length) return str;
			var z:int = 0, el:*, 
				args:Array = [], 
				list:Array = str.split(/(%s|%d\d*|%f\.\d+)/);
			for each (el in more) {
				if (el is Array) args = args.concat(el);
				else args.push(el);
			}
			for (var i:int = 1; i < list.length; i++) {
				var m:Array = list[i].match(/^%(.+)/);
				if (m != null) {
					list[i] = args[z++];
				}
			}
			return list.join("");
		}
		
		public static function randomString(ln:int = 15):String {
			var list:Array = [
				"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
				"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
				"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "_"
			];
			var str:String = "";
			for (var i:int = 0; i < ln; i++) {
				str += list[int(Math.random() * list.length)];
			}
			return str;
		}
		
	}

}