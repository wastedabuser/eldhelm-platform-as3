package eldhelm.ui {
	import eldhelm.constant.UIComponentConstant;
	import eldhelm.interfaces.IUIComponent;
	import eldhelm.interfaces.IUIContainer;
	import eldhelm.util.CallbackManager;
	import eldhelm.util.ObjectUtil;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class UIFrame implements IUIContainer {
		
		public var ptop:Number = 0;
		public var pbottom:Number = 0;
		public var pleft:Number = 0;
		public var pright:Number = 0;
		public var callbackManager:CallbackManager;
		
		protected var _child:IUIComponent;
		protected var _childBehind:IUIComponent;
		protected var _uiParent:IUIContainer;
		
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _outerWidth:Number = 0;
		protected var _outerHeight:Number = 0;
		protected var _innerWidth:Number;
		protected var _innerHeight:Number;
		protected var _elasticWidth:String;
		protected var _elasticHeight:String;
		protected var _visible:Boolean = true;
		
		public function UIFrame(config:Object = null) {
			if (config is IUIComponent) child = config as IUIComponent;
			else {
				ObjectUtil.applyConfig(this, config);
			}
			if (!isNaN(_innerWidth)) computerOuterWidthFromInner();
			if (!isNaN(_innerHeight)) computerOuterHeightFromInner();
			
			callbackManager = new CallbackManager(config);
		}
		
		public function get child():IUIComponent {
			return _child;
		}
		
		public function set child(val:IUIComponent):void {
			_child = val;
			_child.uiParent = this;
		}
		
		public function get childBehind():IUIComponent {
			return _childBehind;
		}
		
		public function set childBehind(val:IUIComponent):void {
			_childBehind = val;
			_childBehind.uiParent = this;
		}	
		
		public function get uiParent():IUIContainer {
			return _uiParent;
		}
		
		public function set uiParent(val:IUIContainer):void {
			_uiParent = val;
		}	
		
		public function get x():Number {
			return _x;
		}
		
		public function set x(val:Number):void {
			_x = val;
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function set y(val:Number):void {
			_y = val;
		}
		
		public function get width():Number {
			return outerWidth;
		}
		
		public function set width(val:Number):void {
			elasticWidth = UIComponentConstant.FIXED_SIZE;
			outerWidth = val;
		}
		
		public function get height():Number {
			return outerHeight;
		}
		
		public function set height(val:Number):void {
			elasticHeight = UIComponentConstant.FIXED_SIZE;
			outerHeight = val;
		}
		
		public function get outerWidth():Number {
			return _outerWidth;
		}
		
		public function set outerWidth(val:Number):void {
			_outerWidth = val;
		}
		
		public function get outerHeight():Number {
			return _outerHeight;
		}
		
		public function set outerHeight(val:Number):void {
			_outerHeight = val;
		}
		
		public function setOuterSize(w:Number, h:Number):void {
			outerWidth = w;
			outerHeight = h;
		}
		
		public function get innerWidth():Number {
			return _outerWidth - pleft - pright;
		}
		
		public function set innerWidth(val:Number):void {
			_innerWidth = val;
		}
		
		public function get innerHeight():Number {
			return _outerHeight - ptop - pbottom;
		}
		
		public function set innerHeight(val:Number):void {
			_innerHeight = val;
		}
		
		public function get elasticWidth():String {
			if (_elasticWidth) return _elasticWidth;
			if (child) return child.elasticWidth;
			return null;
		}
		
		public function set elasticWidth(val:String):void {
			_elasticWidth = val;
		}
		
		public function get elasticHeight():String {
			if (_elasticHeight) return _elasticHeight;
			if (child) return child.elasticHeight;
			return null;
		}
		
		public function set elasticHeight(val:String):void {
			_elasticHeight = val;
		}
		
		public function get padding():Number {
			return pleft;
		}
		
		public function set padding(val:Number):void {
			ptop = pbottom = pleft = pright = val;
		}
		
		public function get plr():Number {
			return pleft;
		}
		
		public function set plr(val:Number):void {
			pleft = pright = val;
		}
		
		public function get ptb():Number {
			return ptop;
		}
		
		public function set ptb(val:Number):void {
			ptop = pbottom = val;
		}
		
		public function get visible():Boolean {
			return _visible;
		}
		
		public function set visible(val:Boolean):void {
			if (_visible == val) return;
			
			_visible = val;
			if (_childBehind) _childBehind.visible = val;
			if (_child) _child.visible = val;
		}
		
		public function doLayoutTo(context:*):void {
			doUiContext(context);
			doOutlines();
		}
		
		public function doUiContext(context:*):void {
			if (_childBehind) _childBehind.doUiContext(context);
			if (_child) _child.doUiContext(context);
		}
		
		public function doLayout():void {
			doOutlines();
		}
		
		public function doOutlines():void {
			doChildOoutlines(childBehind);
			doChildOoutlines(child);
		}
		
		protected function doChildOoutlines(ch:IUIComponent):void {
			if (!ch) return;
			
			ch.setOuterSize(innerWidth, innerHeight);
			ch.x = _x + pleft;
			ch.y = _y + ptop;
			
			if (ch is IUIContainer) (ch as IUIContainer).doOutlines();
		}
		
		public function removeUiContext(context:*):void {
			if (_childBehind) _childBehind.removeUiContext(context);
			if (_child) _child.removeUiContext(context);
		}
		
		public function computeOuterWidth():Number {
			if (!_outerWidth) {
				var ow:Number;
				if (_child is IUIContainer) ow = (_child as IUIContainer).computeOuterWidth();
				else if (_child) ow = _child.outerWidth;
				else ow = 0;
				_outerWidth = ow + pleft + pright;
			}
			return _outerWidth;
		}
		
		public function computeOuterHeight():Number {
			if (!_outerHeight) {
				var oh:Number;
				if (_child is IUIContainer) oh = (_child as IUIContainer).computeOuterHeight();
				else if (_child) oh = _child.outerHeight;
				else oh = 0;
				_outerHeight = oh + ptop + pbottom;
			}
			return _outerHeight;
		}
		
		public function computerOuterWidthFromInner():void {
			_outerWidth = _innerWidth + pleft + pright;
		}
		
		public function computerOuterHeightFromInner():void {
			_outerHeight = _innerHeight + ptop + pbottom
		}
		
		public function destroy():void {
			callbackManager.destroy();
			callbackManager = null;
			if (_child) {
				_child.destroy();
				_child = null;
			}
			if (_childBehind) {
				_childBehind.destroy();
				_childBehind = null;
			}
			_uiParent = null;
		}
	
	}

}