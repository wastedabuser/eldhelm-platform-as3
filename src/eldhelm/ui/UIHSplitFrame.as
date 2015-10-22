package eldhelm.ui {
	import eldhelm.constant.UIComponentConstant;
	import eldhelm.interfaces.IUIComponent;
	import eldhelm.interfaces.IUIContainer;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class UIHSplitFrame extends UIComposite {
		
		public var childWidths:Array;
		public var marginInside:Number = 0;
		
		public function UIHSplitFrame(config:Object = null) {
			super(config);
		}
		
		protected function get totalMarginInside():Number {
			return marginInside * (childs.length - 1);
		}
		
		protected function computeChildWidths():void {
			childWidths = [];
			var cnt:int, tw:Number = 0;
			for (var i:int = 0, l:int = childs.length; i < l; i++) {
				var ch:IUIComponent = childs[i];
				
				if (ch.elasticWidth == UIComponentConstant.AUTO_SIZE) {
					childWidths[i] = 0;
					cnt++;
				} else {
					var ow:Number;
					if (ch is IUIContainer) ow = (ch as IUIContainer).computeOuterWidth();
					else ow = ch.outerWidth;
					tw += ow;
					childWidths[i] = ow;
				}
			}
			if (cnt > 0) {
				var ss:Number = (innerWidth - tw - totalMarginInside) / cnt;
				for (i = 0; i < l; i++) {
					if (childWidths[i] == 0) childWidths[i] = ss;
				}
			}
		}
		
		override public function doOutlines():void {
			if (childs && childs.length) {
				var pos:Number = pleft,
					iw:Number = innerWidth - totalMarginInside
				if (!childWidths) computeChildWidths();
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					var ch:IUIComponent = childs[i],
						w:Number = childWidths[i];
					ch.uiParent = this;
					if (w < 1) w *= iw;
					ch.setOuterSize(w, innerHeight);
					ch.x = _x + pos;
					ch.y = _y + ptop;
					if (ch is IUIContainer) (ch as IUIContainer).doOutlines();
					pos += w + marginInside;
				}
				if (!_outerWidth) _outerWidth = pos - marginInside + pright;
			}
			super.doOutlines();
		}
		
		override public function computeOuterWidth():Number {
			if (!_outerWidth) {
				var ow:Number = 0;
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					var ch:IUIComponent = childs[i];
					if (ch is IUIContainer) ow += (ch as IUIContainer).computeOuterWidth();
					else if (ch) ow += ch.outerWidth;
				}
				_outerWidth = ow + pleft + pright + totalMarginInside;
			}
			return _outerWidth;
		}
		
		override public function computeOuterHeight():Number {
			if (!_outerHeight) {
				var oh:Number = 0, moh:Number = 0;
				for (var i:int = 0, l:int = childs.length; i < l; i++) {
					var ch:IUIComponent = childs[i];
					if (ch is IUIContainer) oh = (ch as IUIContainer).computeOuterHeight();
					else if (ch) oh = ch.outerHeight;
					
					if (oh > moh) moh = oh;
				}
				_outerHeight = moh + ptop + pbottom;
			}
			return _outerHeight;
		}
		
		override public function removeChildren():void {
			super.removeChildren();
			
			if (!childWidths) return;
			childWidths.length = 0;
			childWidths = null;
		}
		
		override public function destroy():void {
			
			super.destroy();
		}
		
	}

}