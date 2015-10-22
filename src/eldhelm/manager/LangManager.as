package eldhelm.manager {
	import eldhelm.event.RequestEvent;
	import eldhelm.event.RpcEvent;
	import eldhelm.network.Request;
	import eldhelm.network.Rpc;
	import eldhelm.util.CallbackManager;
	import eldhelm.util.ObjectUtil;
	import eldhelm.util.StringUtil;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import solar.asset.ObjectResources;
	
	/**
	 * ...
	 * @author ...
	 */
	public class LangManager {
		
		public static const SET_LANG:String = "setLang";
		private static var lang:String;
		private static var repo:Object = { };
		
		private var defaultLang:String;
		private var callbackManager:CallbackManager;
		public var availableLanguages:Array;
		public var embededMap:Object;
		public var localeMap:Object;
		public var localeToCodeMap:Object = {};
		private var retryTimer:Timer;
		
		public function LangManager(config:Object = null) {
			callbackManager = new CallbackManager(config);
			if (config) {
				if (config.defaultLang) {
					defaultLang = config.defaultLang;
					defaultLang = defaultLang.toLocaleLowerCase();
					defaultLang = defaultLang.replace(/-/, '_');
				}
				if (config.lang) setLang(config.lang);
			}
			retryTimer = new Timer(2000, 1);
			retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onRetryTimerComplete, false, 0, true);
		}
		
		public function loadAvailableLangugages():void {
			Rpc.execute( {
				procedure: "index.getAvailableLanguages",
				complete: onLanguagesLoaded
			});
		}
		
		private function onLanguagesLoaded(event:RpcEvent):void {
			availableLanguages = event.data;
			embededMap = ObjectUtil.makeObject(availableLanguages, "code", "embeded");
			localeMap = ObjectUtil.makeObject(availableLanguages, "code", "locale");
			
			for each (var ln:Object in availableLanguages) {
				localeToCodeMap[ln.locale] = ln.code;
				if (ln.altLocale) {
					for each (var al:String in ln.altLocale) localeToCodeMap[al] = ln.code;
				}
			}
			
			var defaultCode:String;
			if (localeMap[defaultLang]) defaultCode = defaultLang;
			else if (localeToCodeMap[defaultLang]) defaultCode = localeToCodeMap[defaultLang];
			else defaultCode = "en";
			
			if (!lang) setLang(loadLang() || defaultCode);
		}
		
		public function loadLang():String {
			return AppManager.storageManager.getVar("language");
		}
		
		public function setLang(name:String, callback:Function = null):void {
			AppManager.storageManager.setVar("language", lang = name);
			
			if (callback != null) callbackManager.one(SET_LANG, callback);
			if (!repo[lang]) loadEmbedded(lang) || loadFile(lang);
			else callbackManager.execute(SET_LANG);
			
			try {
				ExternalInterface.call("EldhelmLangManager.setLang", name);
			} catch (e:Error) {
				
			}
		}
		
		protected function loadEmbedded(name):Boolean {
			var cls:Class = ObjectResources.assetMap["/lang/" + name + ".txt"];
			if (!cls) return false;
			
			var txt:ByteArray = new cls as ByteArray;
			parseLangFile(txt.toString());
			return true;
		}
		
		protected function loadFile(name:String):void {
			MsgManager.startProgress("lang_manager_loading");
			new Request({complete: onLoadText, url: "/data/lang/" + name + ".txt"}).request();
		}
		
		protected function onLoadText(event:RequestEvent):void {
			parseLangFile(event.content);
		}
		
		protected function parseLangFile(str:String):void {
			try {
				var data:Array = JSON.parse(str.replace(/\t*\/\/.+?[\n\r\t]+/g, "")) as Array;
				repo[data[0]] = data[1];
			} catch (e:Error){
				trace(e.name + ": " + e.message);
				retryTimer.start();
				return;
			}
			
			MsgManager.finishProgress();
			callbackManager.execute(SET_LANG);
		}
		
		private function onRetryTimerComplete(event:TimerEvent):void {
			setLang(lang);
		}
		
		public function get curLang():String {
			return lang;
		}
		
		public function get curLocale():String {
			return localeMap[lang];
		}
		
		public function get embeded():Boolean {
			return embededMap[lang];
		}
		
		public function has(name:String):Boolean {
			return repo[lang] && repo[lang][name];
		}
		
		public function getNode(name:String):* {
			if (!repo[lang]) return;
			return repo[lang][name];
		}
		
		public static function text(name:String, chunks:Array = null):String {
			var keys:Array = name.split(".");
			return text2(keys.shift(), keys, chunks);
		}
		
		public static function text2(name:String, pos:* = 0, chunks:Array = null):String {
			if (!repo[lang])
				return "";
			var rf:* = repo[lang][name];
			if (rf is Object && !(rf is String))
				return findProp(rf, pos, chunks);
			return format(rf, chunks);
		}
		
		private static function findProp(rf:Object, pos:*, chunks:Array):String {
			if (pos is Array){
				var ky:* = (pos as Array).shift();
				var val:* = rf[ky];
				if (val == undefined)
					return "";
				if (val is String)
					return format(val, chunks);
				else
					return findProp(rf[ky], pos, chunks);
			}
			return format(rf[pos], chunks);
		}
		
		private static function format(str:String, chunks:Array):String {
			if (!str)
				return "";
			if (chunks == null)
				return str;
			chunks.unshift(str);
			return StringUtil.sprintf.apply(null, chunks);
		}
		
		public static function translateList(list:Array, repo:String, repoKey:String, prop:Array):Array {
			if (!list || list == null) return [];
			var i:int;
			for each (var item:Object in list) {
				i = 0;
				for each (var pr:String in prop) {
					item[pr] = text2(repo, [item[repoKey], i]) || item[pr] || "";
					i++;
				}
			}
			return list;
		}
		
	}

}