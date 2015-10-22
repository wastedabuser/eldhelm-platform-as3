package eldhelm.ui {
	import eldhelm.interfaces.IUIComponent;
	import eldhelm.interfaces.IUIContainer;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class UIGridFrame extends UIComposite {
		
		public var autoColumns:Boolean = true;
		public var autoRows:Boolean;
		public var columns:int;
		public var rows:int;
		public var marginInside:Number = 10;
		
		public function UIGridFrame(config:Object = null) {
			super(config);
		
		}
		
		override public function doOutlines():void {
			if (childs) {
				var l:Number = childs.length,
					mx:Number = 0, 
					my:Number = 0, 
					a:int,
					b:int = 1,
					ma:int, 
					sp:Number = 0, 
					c:int = 0, 
					ch:IUIComponent,
					firstItem:IUIComponent,
					spacing:Number;
				
				if (l > 0) {
					firstItem = childs[0];
					if (autoRows) {
						rows = Math.floor(innerHeight / (firstItem.outerHeight + marginInside)) || 1;
						spacing = firstItem.outerWidth + marginInside;
					} else if (autoColumns) {
						columns = Math.floor(innerWidth / (firstItem.outerWidth + marginInside)) || 1;
						spacing = firstItem.outerHeight + marginInside;
					}
					
					if (columns > 0) {
						ma = columns;
						mx = innerWidth / columns;
						sp = ptop;
					} else if (rows > 0) {
						ma = rows;
						my = innerHeight / rows;
						sp = pleft;
					}
					
					do {
						for (a = 1; a <= ma; a++) {
							if (c >= l) break;
							
							ch = childs[c++];
							ch.x = _x + pleft + (mx ? mx * a - (mx + ch.outerWidth) / 2 : sp);
							ch.y = _y + ptop + (my ? my * a - (my + ch.outerHeight) / 2 : sp);
							if (ch is IUIContainer) (ch as IUIContainer).doOutlines();
						}
						if (a > 1) sp += spacing;
						
					} while (c < l);
					
					if (mx > 0) {
						_outerHeight = firstItem.outerHeight * rows + spacing * (rows - 1) + ptop + pbottom;
					} else if (my > 0) { 
						_outerWidth = firstItem.outerWidth * columns + spacing * (columns - 1) + pleft + pright;
					}
				}
			}
			super.doOutlines();
		}
		
	}

}