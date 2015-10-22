package eldhelm.network {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author ...
	 */
	public class EldhelmSocket extends Socket {
		
		protected static const systemCommand:RegExp = new RegExp(/^-([a-z0-9_]+?)-/);
		protected static const pingCommand:String = "ping";
		protected static const echoCommand:String = "echo";
		public static var sockCnt:int = 1;
		
		public var currentSockCnt:int;
		
		protected var protoHeaderPattern:RegExp;
		protected var stream:String = "";
		protected var buffer:String = "";
		protected var headersContent:String = "";
		protected var contentLength:int = 0;
		protected var debugStream:String;
		protected var showLog:Boolean;
		
		public var headers:Object;
		public var content:Object;
		public var onPing:Function;
		public var onEcho:Function;
		public var onConnect:Function;
		public var onDisconnect:Function;
		public var onReceive:Function;
		public var onError:Function;
		public var onParseError:Function;
		public var onSendError:Function;
		
		public function EldhelmSocket(host:String = null, port:int = 0) {
			sockCnt++;
			currentSockCnt = sockCnt;
			super(host, port);
			configureListeners();
			//showLog = CONFIG::debug;
		}
		
		protected function configureListeners():void {
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		
		protected function socketDataHandler(event:ProgressEvent):void {
			if (showLog) trace("read " + this + ": " + bytesAvailable);
			stream += readUTFBytes(bytesAvailable);
			debugStream = stream;
			while (readSocketData()) { };
		}
		
		public function emulateSockeDataHandler(data:String):void {
			stream += data;
			debugStream = stream;
			while (readSocketData()) { };
		}
		
		protected function connectHandler(event:Event):void {
			if (onConnect is Function) onConnect();
			if (showLog) trace("connect: " + event);
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void {
			if (onError is Function) onError("ioError", "A connection to the server can not be established.", event.text);
			if (showLog) trace("ioErrorHandler: " + event);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void {
			if (onError is Function) onError("securityError", "Data from the server can not be loaded due a security violation.", event.text);
			if (showLog) trace("securityErrorHandler: " + event);
		}
		
		protected function closeHandler(event:Event):void {
			if (onDisconnect is Function) onDisconnect();
			if (showLog) trace("onDisconnect: " + event);
		}
		
		public function sendPing():void {
			sendRequest("-" + pingCommand + "-");
		}
		
		public function sendEcho():void {
			sendRequest("-" + echoCommand + "-");
		}
		
		public function sendRequest(data:*, headers:Object = null):ByteArray {
			var message:ByteArray;
				
			try {
				if (data is String) {					
					//writeUTFBytes(data as String);
					message = new ByteArray;
					message.writeUTFBytes(data as String);
					writeBytes(message);
					
				} else if (data is ByteArray) {
					writeBytes(data as ByteArray);
					
				} else {
					message = new ByteArray;
					var streamBytes:ByteArray = new ByteArray;
					if (data != null) streamBytes.writeUTFBytes(encodePayload(data));
					
					var ln:int = streamBytes.length,
						protocolHeaderStr:String = encodeHeader(ln, headers);
						
					message.writeUTFBytes(protocolHeaderStr);
					if (ln > 0) message.writeBytes(streamBytes);
					
					writeBytes(message);
					
					if (showLog) trace("send " + this + ": " + message.toString());
				}
				flush();
				
			} catch(e:Error) {
				if (showLog) trace(e);
				if (onSendError is Function) onSendError("An error while sending " + e);
			}
			
			return message;
		}
		
		protected function encodePayload(data:*):String {
			throw("should be overwritten");
			return "";
		}
		
		protected function encodeHeader(ln:int, headers:Object):String {
			throw("should be overwritten");
			return "";
		}
		
		protected function readSocketData():Boolean {
			if (!stream) return false;
			
			var m:Array;
			
			// parsing the system commands chunk
			if (!contentLength) {
				m = stream.match(systemCommand);
				if (m != null && m[1] != "json") {
					if (showLog) trace(m[1]);
					stream = stream.replace(systemCommand, "");
					if (m[1] == pingCommand && onPing is Function) onPing();
					else if (m[1] == echoCommand && onEcho is Function) onEcho();
					return true;
				}
			}
			
			// other data
			m = stream.match(protoHeaderPattern);
			if (showLog) trace(stream);
			if (m != null) {
				headers = parseHeader(m);
				contentLength = headers.contentLength;
				stream = stream.replace(protoHeaderPattern, "");
				
				if (!contentLength) {
					if (showLog) trace("receive " + m[0]);
					parseBuffer();
					return true;
				}
			}
			
			if (contentLength > 0) {
				var streamBytes:ByteArray = new ByteArray();
				streamBytes.writeUTFBytes(stream);
				
				var ln:int = streamBytes.length;
				if (showLog) trace("receive " + stream + " got " + ln + " of " + contentLength);
				
				if (ln > contentLength) {
					streamBytes.position = 0;
					buffer += streamBytes.readUTFBytes(contentLength);
					stream = streamBytes.readUTFBytes(streamBytes.bytesAvailable);
					
					contentLength = 0;
					parseBuffer();
					return true;
					
				} else if (ln == contentLength) {
					buffer += stream;
					stream = "";
					contentLength = 0;
					parseBuffer();
					return false;
					
				} else {
					buffer += stream;
					stream = "";
					contentLength = contentLength - ln;
				}				
			} else if (stream.length > 20) {
				var ch:String = stream.charAt(0);
				if (ch != "-" && ch != "[") {
					stream = stream.substr(1);
					return true;
				}
				if (onParseError is Function) onParseError("Unsupported protocol for message 3.12.0: " + m + " => " + stream);
			}
			
			return false;
		}
		
		protected function parseBuffer():void {
			if (buffer) {
				if (showLog) trace("parse " + this + ": " + buffer);
				try {
					content = parsePayload();
				} catch (e:Error) {
					if (showLog) trace(e);
					if (onParseError is Function) onParseError("Can not parse buffer 3.12.0: " + headersContent + " => " + buffer + " => " + debugStream);
					// MsgManager.warn(e.name + ": " + e.message);
				} finally {
					buffer = "";
					headersContent = "";
				}
			}
			if (onReceive is Function) {
				onReceive(content, headers);
				content = null;
				headers = null;
			}
		}
		
		protected function parseHeader(m:Array):Object {
			throw("should be overwritten");
			return null;
		}
		
		protected function parsePayload():Object {
			throw("should be overwritten");
			return null;
		}
		
		public function destroy():void {
			removeEventListener(Event.CLOSE, closeHandler);
			removeEventListener(Event.CONNECT, connectHandler);
			removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			
			onPing = null;
			onEcho = null;
			onConnect = null;
			onDisconnect = null;
			onReceive = null;
			onError = null;
			onParseError = null;
			onSendError = null;
			headers = null;
			content = null;
		}
		
	}

}