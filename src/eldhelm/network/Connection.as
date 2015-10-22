package eldhelm.network {
	import eldhelm.config.ContentVersion;
	import eldhelm.config.Servers;
	import eldhelm.event.ConnectionEvent;
	import eldhelm.manager.AppManager;
	import eldhelm.manager.MsgManager;
	import eldhelm.mvc.Router;
	import eldhelm.util.ObjectUtil;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class Connection extends EventDispatcher {
		
		public var port:Number;
		public var referrer:String = "";
		public var analyticId:int;
		public var sessionId:String = "";
		public var contentVersion:String;
		public var connected:Boolean;
		public var wasConnected:Boolean;
		public var router:Router = new Router;
		
		private var _host:String = "127.0.0.1";
		private var _connectHost:String = "127.0.0.1";
		private var portIndex:int;
		private var sock:EldhelmSocket;
		private var keepAliveTimer:Timer;
		private var recvNextMessageId:int;
		private var recvMaxMessageId:int;
		private var recvMessagesCache:Object;
		private var recvResendToId:int;
		private var sendMessageId:int;
		private var sendMessagesCache:Object;
		private var executedMessages:Object;
		private var resendTimer:Timer = new Timer(5000, 1);
		
		public function Connection(config:Object = null) {
			if (config) {
				if (config.host) host = config.host;
				if (config.referrer) referrer = config.referrer;
				if (config.keepalive) {
					keepAliveTimer = new Timer(config.keepalive * 1000, 1);
					keepAliveTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onKeepaliveTimerComplete, false, 0, true);
				}
			}
			resendTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onResendTimer, false, 0, true);
			resetMessageCache();
		}
		
		public function resetMessageCache():void {
			recvNextMessageId = 1;
			recvMaxMessageId = 0;
			recvMessagesCache = null;
			sendMessageId = 1;
			recvResendToId = 0;
			sendMessagesCache = { };
			executedMessages = { };
			resendTimer.stop();
			resendTimer.reset();
		}
		
		public function set host(h:String):void {
			_host = h;
			_connectHost = h.replace(/:\d+$/, "");
		}
		
		public function get host():String {
			return _host;
		}
		
		private function changePort():Boolean {
			portIndex++;
			if (portIndex >= Servers.ports.length) {
				portIndex = 0; 
				return true;
			}
			return false;
		}
		
		public function disconnect():Boolean {
			if (!connected) return false;
			connected = false;
			
			keepAliveTimer.stop();
			analyticId = 0;
			try {
				sock.close();
			} catch (e:Error) {
				trace(e);
			}
			sock.destroy();
			sock = null;
			
			trace("disconnect");
			return true;
		}
		
		public function connect():Boolean {
			if (connected) return false;
			
			trace("connecting");
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_CONNECT));
			if (sock != null) sock.destroy();
			try {
				sock = new Base64Socket;
				//sock = new JsonSocket;
				//sock = new ConnectionTestJsonSocket;
				//ConnectionTestJsonSocket(sock).muteOutgoing = false;
				
				sock.onConnect = onConnect;
				sock.onDisconnect = onDisconnect;
				sock.onPing = onPing;
				sock.onEcho = onEcho;
				sock.onReceive = onReceive;
				sock.onError = onError;
				sock.onParseError = onSocketError;
				sock.onSendError = onSocketError;
				sock.timeout = 3000;
				sock.connect(_connectHost, port = Servers.ports[portIndex]);
			} catch (e:Error) {
				trace(e);
			}
			return true;
		}
		
		private function onConnect():void {
			onPing();
			sock.sendEcho();
		}
		
		private function onPing():void {
			sock.sendPing();
			keepAliveTimer.reset();
			keepAliveTimer.start();
		}
		
		private function onEcho():void {
			if (connected) return;
			connected = true;
			wasConnected = true;
			
			trace("connected");
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_CONNECTED));
			
			send({ deviceInfo: deviceInfo, analyticId: analyticId }, { type: "deviceInfo" });
			if (sessionId) send( { sessionId: sessionId }, { type: "renewSession" } );
		}
		
		private function onReceive(data:Object, headers:Object):void {
			var msgType:String = headers.type;
			if (msgType) {
				var fn:String = msgType + "Command";
				try {
					this[fn](headers, data);
				} catch (e:Error) {
					trace(e);
				}
				return;
				
			} else if (headers.id > 0) {
				acceptMessage(headers, data);
				return;
			}
			
			route(headers, data);
		}
		
		private function acceptMessage(headers:Object, data:Object):void {
			var msgId:int = headers.id;
			if (msgId > recvMaxMessageId) recvMaxMessageId = msgId;
			
			if (msgId == recvNextMessageId) {
				sendHeader( { type: "ack", id: msgId } );
				recvNextMessageId++;
				route(headers, data);
				
			} else if (msgId > recvNextMessageId) {
				sendHeader( { type: "ack", id: msgId } );
				recvResendToId = msgId - 1;
				resendTimer.start();
				recvMessagesCache ||= { };
				recvMessagesCache[msgId] = [headers, data];
				
			} else {
				return;
			}
			
			if (recvMessagesCache != null) {
				for (var i:int = recvNextMessageId; i <= recvMaxMessageId; i++) {
					if (!recvMessagesCache[i]) return;
				}
				for (i = recvNextMessageId; i <= recvMaxMessageId; i++) {
					route.apply(null, recvMessagesCache[i]);
					delete recvMessagesCache[i];
				}
				recvMessagesCache = null;
				recvNextMessageId = recvMaxMessageId + 1;
			}
		}
		
		private function onResendTimer(event:TimerEvent):void {
			sendHeader( { type: "resend", from: recvNextMessageId, to: recvResendToId } );
		}
		
		private function route(headers:Object, data:Object):void {
			var msgId:int = headers.id;
			if (msgId > 0 && executedMessages[msgId]) 
				return;
			else 
				executedMessages[msgId] = true;
				
			if (headers.rpcId) 
				dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_RPC_RESPONSE, { data: data, headers: headers } ));
			else
				router.route(data);
		}
		
		private function ackCommand(headers:Object, data:Object):void {
			delete sendMessagesCache[headers.id];
		}
		
		private function resendCommand(headers:Object, data:Object):void {
			for (var i:int = headers.from; i <= headers.to; i++) {
				var msg:ByteArray = sendMessagesCache[i];
				if (msg != null) send(msg);
			}
		}
		
		private function signInCommand(headers:Object, data:Object):void {
			var isNew:Boolean = sessionId != data.sessionId,
				oldSessionId:String = sessionId;
				
			sessionId = data.sessionId;
			if (isNew) {
				resetMessageCache();
				if (oldSessionId) 
					dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_SESSION_CLOSED, { sessionId: sessionId, data: data } ));
				dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_SESSION_OPENED, data ));
			} else {
				resendNotAcknowledged();
				dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_SESSION_RENEWED, data ));
			}
		}
		
		private function signOutCommand(headers:Object, data:Object):void {
			var oldSessionId:String = sessionId;
			sessionId = "";
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_SESSION_CLOSED, { sessionId: oldSessionId, data: data } ));
		}
		
		private function denyCommand(headers:Object, data:Object):void {
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_SESSION_DENIED, data ));
		}
		
		private function serverInfoCommand(headers:Object, data:Object):void {
			contentVersion = data.version;
			if (data.analyticId) analyticId = data.analyticId;
			trace("connection ready");
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_CONTENT_VERSION));
		}
		
		private function onDisconnect():void {
			handleDisconnect();
		}
		
		private function onError(type:String = null, msg:String = null, sysMsg:String = null):void {
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_ERROR, { } ));
			if (type != "securityError" && !CONFIG::air) return;
			
			if (changePort() && !wasConnected) {
				trace("server unreachable");
				dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_SERVER_UNREACHABLE));
				handleDisconnect(false);
				return;
			}
			handleDisconnect();
		}
		
		private function onKeepaliveTimerComplete(event:TimerEvent):void {
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_TIMEOUT, { } ));
			handleDisconnect();
		}
		
		private function handleDisconnect(reconnect:Boolean = true):void {
			if (keepAliveTimer != null) keepAliveTimer.stop();
			if (connected) {
				connected = false;
				dispatchEvent(new ConnectionEvent(ConnectionEvent.ON_DISCONNECTED));
			}
			if (reconnect) connect();
		}
		
		private function onSocketError(content:String):void {
			// MsgManager.serverLog(content);
		}
		
		public function sendHeader(headers:Object = null):void {
			sock.sendRequest(null, headers);
		}
		
		public function say(data:Object, headers:Object = null):void {
			if (signedIn) {
				sendMessagesCache[sendMessageId] = send(data, ObjectUtil.extend({ id: sendMessageId }, headers));
				sendMessageId++;
			} else
				send(data, headers);
		}
		
		public function resendNotAcknowledged():void {
			for (var i:String in sendMessagesCache) {
				send(sendMessagesCache[i]);
			}
		}
		
		public function send(data:Object, headers:Object = null):ByteArray {
			return sock.sendRequest(data, headers);
		}
		
		public function get signedIn():Boolean {
			return sessionId != "";
		}
		
		public function get referUrl():String {
			return referrer || host;
		}
		
		public function get deviceInfo():Object {
			return {
				os: Capabilities.os,
				screen: Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY,
				dpi: Capabilities.screenDPI,
				cpu: Capabilities.cpuArchitecture,
				manufacturer: Capabilities.manufacturer,
				refer_url: referUrl,
				content_version: ContentVersion.VERSION,
				platform_code: AppManager.platformCode,
				port: port,
				host: host
			};
		}
		
		public function destroy():void {
			resendTimer.stop();
			resendTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onResendTimer);
			resendTimer = null;
			
			// TODO: Implement destruction of connection object
			router = null;
		}
		
	}

}