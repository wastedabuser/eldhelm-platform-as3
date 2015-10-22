package eldhelm.section {
	import eldhelm.section.Page;
	import eldhelm.util.CallbackManager;
	import solar.constant.EventConstant;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class Section {
		
		public var page:Page;
		public var callbackManager:CallbackManager;
		
		protected var openPage:Class;		
		protected var pageParams:Object;
		protected var onDisplay:Function;
		protected var onClose:Function;
		protected var onCloseParams:Object;
		protected var closing:Boolean = false;
		protected var pageMoving:Boolean;
		protected var pageTransitioning:Boolean;
		protected var pagesHistory:Array = [];
		protected var browsingHistory:Boolean;
		
		private var issuedPage:Class;
		private var issuedPageParams:Object;
		
		public function Section(config:Object) {
			if (config) {
				if (config.openPage) openPage = config.openPage;
				if (config.pageParams) pageParams = config.pageParams;
			}
			callbackManager = new CallbackManager(config);
		}
		
		public function displaySection(callback:Function = null):void {
			if (callback) callbackManager.one(EventConstant.sectionDisplayed, callback);
		}
		
		protected function sectionDisplayed():void {
			callbackManager.execute(EventConstant.sectionDisplayed);
			if (openPage) moveToPage(openPage, pageParams);
		}
		
		public function close(callback:Function = null, params:Object = null):void {
			if (callback) callbackManager.one(EventConstant.sectionClosed, callback, [params]);
			closing = true;
			closePage();
		}
		
		public function moveToPage(cls:Class, params:Object = null):void {
			if (pageMoving) return;
			issuedPage = cls;
			issuedPageParams = params;
			issueMoveToPage();
		}
		
		public function issueMoveToPage():void {
			if (pageMoving) return;
			pageMoving = true;
			if (issuedPageParams == null || !issuedPageParams.omitFromHistory) pagesHistory.push([issuedPage, issuedPageParams]);
			transitionPage(issuedPage, issuedPageParams);
		}
		
		private function transitionPage(cls:Class, params:Object):void {
			if (pageTransitioning) return;
			pageTransitioning = true;
			openPage = cls;
			pageParams = params;
			closePage();
		}
		
		protected function closePage():void {
			if (page) page.close();
			else onPageClosed();
		}
		
		protected function onPageClosed():void {
			page = null;
			if (closing) {
				closeSection();
				return;
			}
			
			if (openPage) {
				displayPage(openPage, pageParams);
				openPage = null;
				pageParams = null;
			}
		}
		
		protected function displayPage(cls:Class, params:Object):void {
			page = new cls(params);
			page.callbackManager.one(EventConstant.pageClosed, onPageClosed);
			page.section = this;
			callbackManager.trigger(EventConstant.pageCreated, page);
			page.displayPage();
			if (page.removeFromHistory && pagesHistory.length && page is lastHistoryEntry[0]) pagesHistory.pop();
			pageTransitioning = false;
			pageMoving = false;
		}
		
		private function get lastHistoryEntry():Array {
			return pagesHistory[pagesHistory.length - 1];
		}
		
		public function goBack():void {
			if (pageTransitioning || pageMoving || closing || pagesHistory.length <= 1) return;
			pagesHistory.pop();
			transitionPage.apply(null, lastHistoryEntry);
		}
		
		public function get hasHistory():Boolean {
			return pagesHistory.length > 1;
		}
		
		protected function closeSection():void {
			sectionClosed();
		}
		
		protected function sectionClosed():void {
			callbackManager.execute(EventConstant.sectionClosed);
			destroy();
		}
		
		public function clearHistory():void {
			pagesHistory.length = 0;
		}
		
		public function destroy():void {
			callbackManager.destroy();
			callbackManager = null;
			page = null;
			openPage = null;
			pageParams = null;
			pagesHistory.length = 0;
			pagesHistory = null;
			issuedPage = null;
			issuedPageParams = null;
		}
		
	}

}