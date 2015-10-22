package eldhelm.network {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class JsonSocket extends EldhelmSocket {
		
		public function JsonSocket(host:String = null, port:uint = 0) {
			protoHeaderPattern = new RegExp(/^(\["eldhlem-json-\d+\.\d+".+?\])/);
			super(host, port);
		}
		
		override public function toString():String {
			return "json-socket-" + currentSockCnt;
		}
		
		override protected function encodePayload(data:*):String {
			return JSON.stringify(data);
		}
		
		override protected function encodeHeader(ln:int, headers:Object):String {
			return '["eldhlem-json-1.1",' + JSON.stringify(ObjectUtil.extend( { contentLength: ln }, headers)) + ']';
		}
		
		override protected function parseHeader(m:Array):Object {
			return JSON.parse(headersContent = m[1])[1];
		}
		
		override protected function parsePayload():Object {
			return JSON.parse(buffer);
		}
		
	}

}