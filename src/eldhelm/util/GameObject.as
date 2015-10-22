package eldhelm.util {
	import eldhelm.util.CallbackManager;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class GameObject {
		
		public static const APPLY_CONFIG:String = "applyConfig";
		protected var _callbackManager:CallbackManager;
		
		public function GameObject(config:Object = null) {
			_callbackManager = new CallbackManager(config);
			if (config) applyConfig(config);
		}
		
		[Inline]
		final public function get callbackManager():CallbackManager {
			return _callbackManager;
		}
		
		public function applyConfig(config:Object, silent:Boolean = true):void {
			ObjectUtil.applyConfig(this, config);
			if (!silent) _callbackManager.trigger(APPLY_CONFIG, this, config);
		}
		
		public function get destroyed():Boolean {
			return !_callbackManager;
		}
		
		public function destroy():void {
			_callbackManager.destroy();
			_callbackManager = null;
		}
		
	}

}