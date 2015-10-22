package eldhelm.starling {
	import eldhelm.manager.AppManager;
	import eldhelm.util.Percent;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class StarlingPositionUtil {
		
		private static var _margin:Vector.<int> = Vector.<int>([0, 0, 0, 0]);
		
		public static function get margin():Vector.<int> {
			return _margin;
		}
		public static function set margin(value:Vector.<int>):void {
			_margin = value;
		}
		public static function setMarginNumber(value:int):void {
			if (value is int || value is Number) setMargin(value, value, value, value);
			else if (value is Array) setMargin(value[0], value[1], value[2], value[3]);
		}
		public static function setMargin(top:int, right:int, bottom:int, left:int):void {
			_margin[0] = top;
			_margin[1] = right;
			_margin[2] = bottom;
			_margin[3] = left;
		}
		
		public static function positionHorizontaly(self:*, percent:String):void {
			self.x = AppManager.stageWidth * Percent.stringToNumber(percent) - self.width / 2 + self.pivotX;
		}
		
		public static function positionVerticaly(self:*, percent:String):void {
			self.y = AppManager.stageHeight * Percent.stringToNumber(percent) - self.height / 2 + self.pivotY;
		}
		
		public static function toStageCenterHorizontaly(self:*):void {
			self.x = margin[3] + AppManager.stageWidth / 2 + self.pivotX;
		}
		
		public static function toStageCenterVerticaly(self:*):void {
			self.y = margin[0] + AppManager.stageHeight / 2 + self.pivotY;
		}
		
		public static function centerVerticaly(self:*):void {
			self.y = AppManager.stageHeight / 2 - self.height / 2 + (self.pivotY * self.scaleY);
		}
		
		public static function centerHorizontaly(self:*):void {
			self.x = AppManager.stageWidth / 2 - self.width / 2 + (self.pivotX * self.scaleX);
		}
		
		public static function onBottomOf(self:*, obj:* = null):void {
			if (obj != null) self.y = obj.y + obj.height + self.pivotY + margin[0];
			else self.y = margin[0] + self.pivotY;
		}
		
		public static function onTopOf(self:*, obj:* = null):void {
			if (obj != null) self.y = obj.y - self.height + self.pivotY - margin[2];
			else self.y = AppManager.stageHeight - self.height + self.pivotY - margin[2];
		}
		
		public static function onRightOf(self:*, obj:* = null):void {
			if (obj != null) self.x = obj.x + obj.width - obj.pivotX + self.pivotX + margin[3];
			else self.x = margin[3] + self.pivotX;
		}
		
		public static function onLeftOf(self:*, obj:* = null):void {
			if (obj != null) self.x = obj.x - obj.pivotX - self.width + self.pivotX - margin[1];
			else self.x = AppManager.stageWidth - self.width + self.pivotX - margin[3];
		}
		
		public static function bellowScreen(self:*):void {
			self.y = AppManager.stageHeight;
		}
		
		public static function centerToStage(self:*):void {
			toStageCenterHorizontaly(self);
			toStageCenterVerticaly(self);
		}
		
		public static function alignCenter(self:*):void {
			centerHorizontaly(self);
			centerVerticaly(self);
		}
		
		public static function alignRight(self:*, obj:* = null):void {
			onLeftOf(self, obj);
			centerVerticaly(self);
		}
		
		public static function alignLeft(self:*, obj:* = null):void {
			onRightOf(self, obj);
			centerVerticaly(self);
		}
		
		public static function alignBottom(self:*, obj:* = null):void {
			centerHorizontaly(self);
			onTopOf(self, obj);
		}
		
		public static function alignTop(self:*, obj:* = null):void {
			centerHorizontaly(self);
			onBottomOf(self, obj);
		}
		
		public static function onBottomRightOf(self:*, bottom:* = null, right:* = null):void {
			onBottomOf(self, bottom);
			onRightOf(self, right);
		}
		
		public static function onBottomLeftOf(self:*, bottom:* = null, left:* = null):void {
			onBottomOf(self, bottom);
			onLeftOf(self, left);
		}
		
		public static function onTopRightOf(self:*, top:* = null, right:* = null):void {
			onTopOf(self, top);
			onRightOf(self, right);
		}
		
		public static function onTopLeftOf(self:*, top:* = null, left:* = null):void {
			onTopOf(self, top);
			onLeftOf(self, left);
		}
		
	}

}