package eldhelm.section {
	import eldhelm.section.Section;
	import eldhelm.util.CallbackManager;
	import solar.constant.EventConstant;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class Page {
		
		public var callbackManager:CallbackManager;	
		public var section:Section;
		public var removeFromHistory:Boolean;
		
		public function Page(config:Object) {
			callbackManager = new CallbackManager(config);
		}
		
		public function close(callback:Function = null):void {
			if (callback) callbackManager.one(EventConstant.pageClosed, callback);
			closePage();
		}
		
		protected function closePage():void {
			pageClosed();
		}
		
		protected function pageClosed():void {
			callbackManager.execute(EventConstant.pageClosed);
			destroy();
		}
		
		public function displayPage():void {
			pageDisplayed();
		}
		
		public function pageDisplayed():void {
			callbackManager.execute(EventConstant.pageDisplayed);
		}
		
		public function destroy():void {
			callbackManager.destroy();
			callbackManager = null;
			section = null;
		}
	}

}