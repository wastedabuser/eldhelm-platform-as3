package eldhelm.mvc {
	import eldhelm.manager.AppManager;
	import eldhelm.util.StringUtil;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class Router {
		
		public function Router() {
			
		}
		
		public function route(data:Object):void {
			if (data != null) {
				if (data is Array) {
					for (var i:int = 0; i < data.length; i++)
						doAction(data[i]);
				} else
					doAction(data);
			}
		}
		
		private function doAction(data:Object):void {
			var action:String = data.action || data.type + ":" + data.command;
			if (!action) {
				trace("Router: No action specified");
				return;
			}
			var parts:Array = action.split(":"),
				chunks:Array = parts[0].split("."),
				name:String = StringUtil.ucFirst(chunks.pop()),
				ns:String = chunks.length ? chunks.join(".") + "." : "",
				method:String = parts[1],
				recvData:* = data.data;
			
			if (CONFIG::debug) {
				callAction(ns, name, method, recvData);
			} else {
				try {
					callAction(ns, name, method, recvData);
				} catch (e:Error) {
					trace("Router: Error calling action " + action + " " + e);
				}
			}
		}
		
		private function callAction(ns:String, name:String, method:String, data:*):void {
			var cls:Class = getDefinitionByName(AppManager.controllerNamespace + "." + ns + name) as Class;
			cls[method](data);
		}
		
	}

}