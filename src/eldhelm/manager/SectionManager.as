package eldhelm.manager {
	import eldhelm.section.Section;
	import eldhelm.util.CallbackManager;
	import eldhelm.util.CallLater;
	import flash.utils.getDefinitionByName;
	import solar.constant.EventConstant;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class SectionManager {
		
		private static var sectionTransitioning:Boolean;
		
		public static var section:Section;
		public static var callbackManager:CallbackManager = new CallbackManager;
		
		public static function moveToSectionName(name:String, params:Object = null):void {
			var cls:Class = getDefinitionByName(AppManager.sectionNamespace + "." + name) as Class;
			moveToSection(cls, params);
		}
		
		public static function moveToSection(cls:Class, params:Object = null):void {
			if (sectionTransitioning) return;
			sectionTransitioning = true;
			
			var args:Object = { cls: cls, params: params };
			if (section != null) {
				section.close(openNewSection, args);
				callbackManager.trigger(EventConstant.sectionClosing, args);
			} else 
				openNewSection(args);
		}
		
		private static function openNewSection(args:Object):void {
			var config:Object = args.params || { };
			section = new args.cls(config);
			section.displaySection(onSectionDisplayed);
		}
		
		private static function onSectionDisplayed():void {
			sectionTransitioning = false;
		}
		
		public static function moveToPage(page:Class, params:Object = null):void {
			section.moveToPage(page, params);
		}
		
		public static function moveToPageWithinSection(cls:Class, pcls:Class, pageParams:Object = null):void {
			if (section is cls) {
				section.moveToPage(pcls, pageParams);
				return;
			}
			
			moveToSection(cls, { openPage: pcls, pageParams: pageParams } );
		}
		
	}

}