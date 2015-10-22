package eldhelm.interfaces {
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public interface IUIComponent {
		
		function set x(val:Number):void;
		function set y(val:Number):void;
		function set visible(val:Boolean):void;
		
		function get outerWidth():Number;
		function set outerWidth(val:Number):void;
		function get outerHeight():Number;
		function set outerHeight(val:Number):void;
		function setOuterSize(w:Number, h:Number):void;
		
		function get elasticWidth():String;
		function get elasticHeight():String;
		
		function get uiParent():IUIContainer;
		function set uiParent(val:IUIContainer):void;
		
		function doUiContext(context:*):void;
		function removeUiContext(context:*):void;
		
		function destroy():void;
		
	}

}