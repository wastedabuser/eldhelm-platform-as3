package eldhelm.ui {
	import eldhelm.interfaces.IUIComponent;
	import eldhelm.interfaces.IUIContainer;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class UIComposite extends UIFrame implements IUIContainer {
		
		public var childs:Vector.<IUIComponent>;	
		
		public function UIComposite(config:Object = null) {
			super(config);
		
		}
		
		override public function set visible(val:Boolean):void {
			if (_visible == val) return;
			
			super.visible = val;
			if (childs) {
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					childs[i].visible = val;
				}
			}
		}
		
		override public function doUiContext(context:*):void {
			super.doUiContext(context);
			if (childs) {
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					childs[i].doUiContext(context);
				}
			}
		}
		
		override public function removeUiContext(context:*):void {
			if (childs) {
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					childs[i].removeUiContext(context);
				}
			}
			super.removeUiContext(context);
		}
		
		override public function get elasticWidth():String {
			if (_elasticWidth) return _elasticWidth;
			if (childs) {
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					var ew:String = childs[i].elasticWidth;
					if (ew) return ew;
				}
			}
			return null;
		}
		
		override public function get elasticHeight():String {
			if (_elasticHeight) return _elasticHeight;
			if (childs) {
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					var eh:String = childs[i].elasticHeight;
					if (eh) return eh;
				}
			}
			return null;
		}
		
		public function removeChildren():void {
			if (!childs) return;
			childs.length = 0;
			
		}
		
		public function destroyChildren():void {
			if (childs) {
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					childs[i].destroy();
				}
			}
			removeChildren();
		}
		
		override public function destroy():void {
			destroyChildren();
			if (childs) childs = null;
			super.destroy();
		}
		
	}

}