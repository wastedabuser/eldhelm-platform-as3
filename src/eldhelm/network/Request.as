package eldhelm.network {
	import eldhelm.config.Servers;
	import eldhelm.event.RequestEvent;
	import eldhelm.manager.MsgManager;
	import eldhelm.util.ObjectUtil;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import eldhelm.manager.AppManager;
	import eldhelm.network.Connection;
	import flash.net.URLVariables;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class Request extends EventDispatcher {
		
		public var host:String = Servers.selectedServer;
		public var uri:String;
		public var url:String;
		public var method:String;
		public var params:Object;
		public var data:*;
		public var callbackParams:Object;
		public var loader:URLLoader;
		public var suppressMessages:Boolean;
		public var autoDestroy:Boolean;
		
		private var success:Function;
		private var fail:Function;
		
		public static function execute(config:Object):void {
			config.autoDestroy = true;
			new Request(config).request();
		}
		
		public function Request(config:Object = null) {
			if (config) {
				if (config.suppressMessages) suppressMessages = config.suppressMessages;
				if (config.host) host = config.host;
				if (config.uri) uri = config.uri;
				if (config.url) url = config.url;
				if (config.method) method = config.method;
				if (config.params) params = config.params;
				if (config.data) data = config.data;
				if (config.autoDestroy) autoDestroy = config.autoDestroy;
				if (config.callbackParams) callbackParams = config.callbackParams;
				if (config.fail || config.complete) {
					fail = config.fail || config.complete;
					addEventListener(RequestEvent.ON_FAIL, fail, false, 0, true);
				}
				if (config.success || config.complete) {
					success = config.success || config.complete;
					addEventListener(RequestEvent.ON_SUCCESS, success, false, 0, true);
				}
			}
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onReceive);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
		
		public function request(reqParams:Object = null):void {
			var request:URLRequest = new URLRequest(uri ? uri : Servers.httpPref + host + url);
			var variables:URLVariables = new URLVariables;
			if (data) variables.jsonData = JSON.stringify(data);
			if (params) ObjectUtil.extend(variables, params);
			if (reqParams) ObjectUtil.extend(variables, reqParams);
			if (method) request.method = method;
			request.data = variables;
			loader.load(request);
		}
		
		protected function onReceive(event:Event):void {
			var evParams:Object = ObjectUtil.extend( { 
				content: loader.data,
				data: decodeData(loader.data)
			}, callbackParams);
			
			dispatchEvent(new RequestEvent(RequestEvent.ON_SUCCESS, evParams));
			
			if (autoDestroy) destroy();
		}
		
		protected function decodeData(content:String):Object {
			return null;
		}
		
		protected function onError(event:IOErrorEvent):void {
			if (!suppressMessages) MsgManager.warn(event.text);
			dispatchEvent(new RequestEvent(RequestEvent.ON_FAIL, { 
				data: loader.data
			} ));
			
			if (autoDestroy) destroy();
		}
		
		protected function onSecurityError(event:SecurityErrorEvent):void {
			if (!suppressMessages) MsgManager.warn(event.text);
			dispatchEvent(new RequestEvent(RequestEvent.ON_FAIL, { 
				data: loader.data
			} ));
			
			if (autoDestroy) destroy();
		}
		
		public function destroy():void {
			if (success != null) {
				removeEventListener(RequestEvent.ON_SUCCESS, success);
				success = null;
			}
			if (fail != null) {
				removeEventListener(RequestEvent.ON_FAIL, fail);
				fail = null;
			}
			loader.removeEventListener(Event.COMPLETE, onReceive);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader = null;
			callbackParams = null;
			params = null;
		}
		
	}

}