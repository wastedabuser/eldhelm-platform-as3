package eldhelm.util {
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class DateFormat {
		
		public static var dayNamesShort:Array = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		public static var dayNamesLong:Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		public static var monthNamesShort:Array = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		public static var monthNamesLong:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		
		// Bellow the properties mean
		// [property from Date, leading zero, addition]
		private static var keys:Object = {
			"Y": ["getFullYear", false],
			"m": ["getMonth", true, 1],
			"d": ["getDate", true],
			"H": ["getHours", true],
			"i": ["getMinutes", true],
			"s": ["getSeconds", true],
			"S": ["getSeconds", true]
		};
		
		private static var wordKeys:Object = {
			"w": ["getDay", "dayNamesLong"],
			"a": ["getDay", "dayNamesShort"],
			"b": ["getMonth", "monthNamesShort"],
			"M": ["getMonth", "monthNamesLong"]
		}
		
		private static var complexKeys:Object = {
			"T": ["%H:%i:%s"]
		};
		
		public static function format(fmt:String, date:Date = null):String {
			var list:Array = fmt.split("%");
			if (list.length > 1) {
				if (!date) date = new Date;
				var codes:Array = [];
				var chunks:Array = [list[0]];
				for (var i:int = 1, l:int = list.length; i < l; i++) {
					var ch:String = list[i];
					codes.push(ch.charAt(0));
					chunks.push(ch.substring(1, ch.length));
				}
				var formated:String = "";
				for (i = 0; i < l; i++) {
					formated += chunks[i] + formatCode(codes[i], date);
				}
				return formated;
			} else 
				return fmt;
		}
		
		public static function formatCode(code:String, date:Date):String {
			if (keys[code]) {
				var val:String = date[keys[code][0]]();
				if (keys[code][2]) val = String(int(val) + keys[code][1]);
				if (keys[code][1] && int(val) < 10) return "0" + val;
				return val;
			}
			if (wordKeys[code]) {
				var index:int = date[wordKeys[code][0]]();
				return DateFormat[wordKeys[code][1]][index];
			}
			if (complexKeys[code]) {
				return format(complexKeys[code], date);
			}
			return "";
		}
		
		private static var tmpDate:Date = new Date;
		public static function unixTimestampToDate(unixTimestamp:int):Date {
			tmpDate.setTime(unixTimestamp * 1000);
			return tmpDate;
		}
		
		private static const dateTime:Number = new Date().getTime();
		private static const dateTimestamp:int = getTimer();
		public static function get currentTimestamp():Number {
			return dateTime + (getTimer() - dateTimestamp);
		}
		
		/**
		 * Formats time in seconds
		 * @param	fmt
		 * @param	stmp
		 * @return
		 */
		public static function formatUnixTimestamp(fmt:String, stmp:Number):String {
			return format(fmt, unixTimestampToDate(stmp));
		}
		
		/**
		 * Formats time in miliseconds
		 * @param	fmt
		 * @param	stmp
		 * @return
		 */
		public static function formatTimestamp(fmt:String, stmp:Number):String {
			tmpDate.setTime(stmp);
			return format(fmt, tmpDate);
		}
		
	}

}