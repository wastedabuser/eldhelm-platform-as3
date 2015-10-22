package eldhelm.interfaces {
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public interface IUIContainer extends IUIComponent {
		
		function get innerWidth():Number;
		function get innerHeight():Number;
		
		function computeOuterWidth():Number;
		function computeOuterHeight():Number;
		
		function doLayoutTo(context:*):void;
		function doOutlines():void;
	}

}