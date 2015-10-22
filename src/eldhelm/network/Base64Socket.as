package eldhelm.network {
	import eldhelm.util.Base64;
	import eldhelm.util.ObjectUtil;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Base64Socket extends EldhelmSocket {
		
		public function Base64Socket(host:String = null, port:int = 0) {
			protoHeaderPattern = new RegExp(/^BASE64ELDHELM02(.+?)PAYLOAD/);
			super(host, port);
		}
		
		override public function toString():String {
			return "base64-socket-" + currentSockCnt;
		}
		
		override protected function encodePayload(data:*):String {
			var bar:ByteArray = new ByteArray();
			bar.writeUTFBytes(JSON.stringify(data));
			return Base64.encode(bar);
		}
		
		override protected function encodeHeader(ln:int, headers:Object):String {
			var bar:ByteArray = new ByteArray();
			bar.writeUTFBytes(JSON.stringify(ObjectUtil.extend( { contentLength: ln }, headers)));
			return 'BASE64ELDHELM02' + Base64.encode(bar) + 'PAYLOAD';
		}
		
		override protected function parseHeader(m:Array):Object {
			headersContent = m[1];
			var arr:ByteArray = Base64.decode(headersContent);
			arr.position = 0;
			var jsn:String = arr.readUTFBytes(arr.bytesAvailable);
			return JSON.parse(jsn);
		}
		
		override protected function parsePayload():Object {
			var arr:ByteArray = Base64.decode(buffer);
			arr.position = 0;
			var jsn:String = arr.readUTFBytes(arr.bytesAvailable);
			return JSON.parse(jsn);
		}
	
	}

}