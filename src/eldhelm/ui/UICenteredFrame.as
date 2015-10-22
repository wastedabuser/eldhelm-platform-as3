package eldhelm.ui {
	import eldhelm.interfaces.IUIComponent;
	import eldhelm.interfaces.IUIContainer;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class UICenteredFrame extends UIFrame {
		
		public function UICenteredFrame(config:Object = null) {
			super(config);
		}
		
		override protected function doChildOoutlines(ch:IUIComponent):void {
			if (!ch) return;
			
			ch.x = _x + pleft + (innerWidth - ch.outerWidth) / 2;
			ch.y = _y + ptop + (innerHeight - ch.outerHeight) / 2;
			
			if (ch is IUIContainer) (ch as IUIContainer).doOutlines();
		}
		
	}

}