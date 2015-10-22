package eldhelm.ui {
	import eldhelm.constant.UIComponentConstant;
	import eldhelm.interfaces.IUIComponent;
	import eldhelm.interfaces.IUIContainer;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class UIVSplitFrame extends UIComposite {
		
		public var childHeights:Array;
		public var marginInside:Number = 0;
		
		public function UIVSplitFrame(config:Object = null) {
			super(config);
		}
		
		protected function get totalMarginInside():Number {
			return marginInside * (childs.length - 1);
		}
		
		protected function computeChildHeights():void {
			childHeights = [];
			var cnt:int, th:Number = 0;
			for (var i:int = 0, l:int = childs.length; i < l; i++) {
				var ch:IUIComponent = childs[i];
				
				if (ch.elasticHeight == UIComponentConstant.AUTO_SIZE) {
					childHeights[i] = 0;
					cnt++;
				} else {
					var oh:Number;
					if (ch is IUIContainer) oh = (ch as IUIContainer).computeOuterHeight();
					else oh = ch.outerHeight;
					th += oh;
					childHeights[i] = oh;
				}
			}
			if (cnt > 0) {
				var ss:Number = (innerHeight - th - totalMarginInside) / cnt;
				for (i = 0; i < l; i++) {
					if (childHeights[i] == 0) childHeights[i] = ss;
				}
			}
		}
		
		override public function doOutlines():void {
			if (childs && childs.length) {
				var pos:Number = ptop,
					ih:Number = innerHeight - totalMarginInside;
				if (!childHeights) computeChildHeights();
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					var ch:IUIComponent = childs[i],
						h:Number = childHeights[i];
					ch.uiParent = this;
					if (h < 1) h *= ih;
					ch.setOuterSize(innerWidth, h);
					ch.x = _x + pleft;
					ch.y = _y + pos;
					if (ch is IUIContainer) (ch as IUIContainer).doOutlines();
					pos += h + marginInside;
				}
				if (!_outerHeight) _outerHeight = pos - marginInside + pbottom;
			}
			super.doOutlines();
		}
		
		override public function computeOuterWidth():Number {
			if (!_outerWidth) {
				var ow:Number = 0, mow:Number = 0;
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					var ch:IUIComponent = childs[i];
					if (ch is IUIContainer) ow = (ch as IUIContainer).computeOuterWidth();
					else if (ch) ow = ch.outerWidth;
					
					if (ow > mow) mow = ow;
				}
				_outerWidth = mow + pleft + pright;
			}
			return _outerWidth;
		}
		
		override public function computeOuterHeight():Number {
			if (!_outerHeight) {
				var oh:Number = 0;
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					var ch:IUIComponent = childs[i];
					if (ch is IUIContainer) oh += (ch as IUIContainer).computeOuterHeight();
					else if (ch) oh += ch.outerHeight;
				}
				_outerHeight = oh + ptop + pbottom + totalMarginInside;
			}
			return _outerHeight;
		}
		
		override public function removeChildren():void {
			super.removeChildren();
			
			if (!childHeights) return;
			childHeights.length = 0;
			childHeights = null;
		}
		
		override public function destroy():void {
			
			super.destroy();
		}
		
	}

}