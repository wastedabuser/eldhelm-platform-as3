package eldhelm.util {
	import eldhelm.manager.AppManager;
	import eldhelm.manager.LangManager;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class DataMapper {
		
		protected var langManager:LangManager = AppManager.langManager;
		
		public var params:Object = {};
		public var _props:Array = [];
		public var _multilangRepo:String = "";
		public var _multilangRepoKey:String = "";
		public var _multilangProps:Array = [];
		public var callbackManager:CallbackManager;
		public var undestructable:Boolean;
		
		public function DataMapper(config:Object = null) {
			callbackManager = new CallbackManager(config);
			if (config) setData(config);
		}
		
		public function setData(config:Object, silent:Boolean = false):void {
			var i:String, fn:String;
			ObjectUtil.extend(params, config);
			for (i in config) {
				if (!this.hasOwnProperty(i)) continue;
				fn = "setData_" + i;
				if (this.hasOwnProperty(fn)) {
					if (this[fn] is Function) this[fn](config[i]);
				} else if (this[i] is Boolean) {
					this[i] = Boolean(int(config[i]))
				} else if (typeof this[i]) {
					this[i] = config[i];
				}
			}
			translate();
			if (!silent) callbackManager.trigger(EventConstant.setData, this, config);
		}
		
		protected function translate():void {
			if (!_multilangRepo || !_multilangRepoKey || !this[_multilangRepoKey]) return;
			var i:int = 0, fn:String;
			for each (var nm:String in _multilangProps) {
				fn = "translate_" + nm;
				var rf:Object = this.hasOwnProperty(nm) ? rf = this : rf = params;
				if (this.hasOwnProperty(fn) && this[fn] is Function) rf[nm] = this[fn](nm, params); 
				else rf[nm] = langManager.text(_multilangRepo, [rf[_multilangRepoKey], i]) || rf[nm];
				i++;
			}
		}
		
		public function toJSON():Object {
			var jsn:Object = {};
			for (var i:int = 0; i < _props.length; i++ ) {
				var ky:String = _props[i];
				jsn[ky] = this[ky];
			}
			return jsn;
		}
		
		public function destroy():void {
			if (callbackManager != null) {
				callbackManager.destroy();
				callbackManager = null;
			}
			params = null;
			langManager = null;
			_props.length = 0;
			_props = null;
			_multilangProps.length = 0;
			_multilangProps = null;
		}
		
	}

}