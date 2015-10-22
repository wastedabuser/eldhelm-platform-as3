package eldhelm.event {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ImageLibraryEvent extends Event {
		
		public static const ON_NOTHING_TO_LOAD:String = "onNothingToLoad";
		
		public var params:Object;
		
		public function ImageLibraryEvent(type:String, params:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this.params = params;
			//if (params) {
				//if (params.data) data = params.data;
				//if (params.progress) progress = params.progress;
				//if (params.url) url = params.url;
				//if (params.error) error = params.error;
			//}
		} 
		
		public override function clone():Event { 
			return new ImageLibraryEvent(type, params, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ImageLibraryEvent", "params", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}