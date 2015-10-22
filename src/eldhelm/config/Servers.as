package eldhelm.config {
	import eldhelm.manager.AppManager;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class Servers {
		
		public static const httpPref:String = "http://";
		
		public static const ports:Array = [10137, 20137, 80];
		public static const servers:Array = [
			
		];
		public static var selectedServer:String;
		
		public static function getAll(list:Array = null):Array {
			var serverList:Array = list != null && list.length > 0 ? list : servers.concat();
			if (CONFIG::debug) serverList.unshift( 
				{ host: "127.0.0.1" }
			);
			return serverList;
		}
		
		public static function get coordinatorServer():String {
			return null;
		}
		
		public static function get cdnServer():String {
			return null;
		}
		
		public static function get analyticUrl():String {
			return CONFIG::debug ? "127.0.0.1:8002" : "78.128.6.60:10280";
		}
		
		public static const cdnMaxConnections:int = 12;
		
	}

}