package eldhelm.input {
	import flash.ui.GameInputDevice;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class GameInputMapping {
		
		public var code:String;
		public var deviceMatch:RegExp;
		public var controls:Object;
		public var isGameController:Boolean;
		
		public function GameInputMapping($code:String, $deviceMatch:RegExp, $controls:Object = null) {
			code = $code;
			deviceMatch = $deviceMatch;
			
			if ($controls) {
				controls = $controls;
				isGameController = true;
			} else 
				controls = { };
		}
		
		public function match(device:GameInputDevice):Boolean {
			return deviceMatch.test(device.name);
		}
		
	}

}