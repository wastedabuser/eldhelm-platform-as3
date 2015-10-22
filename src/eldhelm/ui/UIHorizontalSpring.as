package eldhelm.ui {
	import eldhelm.constant.UIComponentConstant;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class UIHorizontalSpring extends UIFrame {
		
		public function UIHorizontalSpring(config:Object=null) {
			super(config);
			elasticWidth = UIComponentConstant.AUTO_SIZE;
		}
		
	}

}