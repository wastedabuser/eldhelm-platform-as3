package eldhelm.util {
	
	import eldhelm.manager.AppManager;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MessageBox extends Sprite {
		
		public static function show(text:String):void {
			var sprt:MessageBox = new MessageBox(text);
			AppManager.stage.addChild(sprt);
			sprt.x = (AppManager.screenWidth - sprt.width) / 2;
			sprt.y = (AppManager.screenHeight - sprt.height) / 2;
		}
		
		function MessageBox(text:String):void {
			var format:TextFormat = new TextFormat;
			format.align = TextFormatAlign.CENTER;
			format.color = 0xFF0000;
			format.size = 24;
			format.font = "Verdana";
			
			var textfield:TextField = new TextField();
			textfield.defaultTextFormat = format;
			textfield.multiline = true;
			textfield.wordWrap = true;
			textfield.autoSize = TextFieldAutoSize.CENTER;
			textfield.width = 300;
			textfield.text = text;
			
			var msgbox:Sprite = new Sprite();
			msgbox.graphics.beginFill(0x000000);
			msgbox.graphics.drawRect(0, 0, textfield.width, textfield.height);
			msgbox.graphics.endFill();
			msgbox.graphics.lineStyle(2, 0xFF0000, 100);
			msgbox.graphics.drawRect(0, 0, textfield.width, textfield.height);
			
			addChild(msgbox);
			addChild(textfield);
		}
	}
}