package eldhelm.ui {
	import eldhelm.interfaces.IUIComponent;
	import eldhelm.interfaces.IUIContainer;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class UICardLayout extends UIComposite {
		
		public function UICardLayout(config:Object = null) {
			super(config);
		
		}
		
		override public function doOutlines():void {
			if (childs) {
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					var ch:IUIComponent = childs[i];
					ch.uiParent = this;
					doChildOoutlines(ch);
					if (ch is IUIContainer) (ch as IUIContainer).doOutlines();
				}
			}
			super.doOutlines();
		}
		
	}

}