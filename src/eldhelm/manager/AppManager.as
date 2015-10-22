package eldhelm.manager {
	import eldhelm.air.ImageLibraryAir;
	import eldhelm.constant.EldEventConstant;
	import eldhelm.manager.ImageLibrary;
	import eldhelm.network.Connection;
	import eldhelm.storage.StorageManager;
	import eldhelm.util.CallbackManager;
	import eldhelm.util.EldLater;
	import eldhelm.util.EldTimer;
	import eldhelm.util.MessageBox;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class AppManager {
		
		public static const WIDE_SCRREN_RATIO:Number = 16 / 10;
		
		// size of the screen in points the game is designed to handle
		public static var baseWidth:int;
		public static var baseHeight:int;
		
		// the resolution of the device screen
		public static var screenWidth:int;
		public static var screenHeight:int;
		public static var screenCode:String;
		public static var screenRatio:Number;
		
		// the dimension of the stage
		public static var stageWidth:int;
		public static var stageHeight:int;
		public static var stage:Stage;
		public static var scale:Number;
		public static var stageRectangle:Rectangle;
		public static var stageCenter:Point;
		public static var stageDiagonal:Number;
		public static var stageHalfDiagonal:Number;
		public static var frameRate:Number;
		public static var oneFrameTime:Number;
		
		public static var args:Array;
		public static var sectionNamespace:String = "eldhelm.section";
		public static var pageNamespace:String = "eldhelm.section";
		public static var controllerNamespace:String = "eldhelm.controller";
		public static var platformCode:String;
		public static var mobile:Boolean;
		public static var isWeb:Boolean;
		
		public static var callbackManager:CallbackManager = new CallbackManager;
		public static var later:EldLater = new EldLater;
		public static var timer:EldTimer = new EldTimer;
		public static var imageLibrary:ImageLibrary;
		public static var langManager:LangManager;
		public static var storageManager:StorageManager;
		public static var connection:Connection;
		
		public static function get isDevelopmentOs():Boolean {
			return Capabilities.os == "Windows 7" || Capabilities.os == "Windows 8";
		}
		
		public static function get isWideScreen():Boolean {
			return screenRatio >= WIDE_SCRREN_RATIO;
		}
		
		private static var _displayInches:Number;
		public static function get displayInches():Number {
			if (!_displayInches) {
				var w:Number = Capabilities.screenResolutionX / Capabilities.screenDPI,
					h:Number = Capabilities.screenResolutionY / Capabilities.screenDPI;	
				_displayInches = Math.sqrt(Math.pow(w, 2) + Math.pow(h, 2));
			}
			return _displayInches;
		}
		
		public static function get fingerWidth():int {
			return scale * Capabilities.screenDPI * .7;
		}
		
		public static function catchErrorOn(target:Sprite):void {
			target.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleGlobalErrors);
		}
		
		private static function handleGlobalErrors(event:UncaughtErrorEvent):void {		
			var message:String;
			if (event.error is Error) {
				message = Error(event.error).message;
			} else if (event.error is ErrorEvent){
				message = ErrorEvent(event.error).text;
			} else {
				message = event.error.toString();
			}
			MessageBox.show(message);
			callbackManager.trigger(EldEventConstant.error, message);
		}
		
		public static function setBase(w:int, h:int):void {
			baseWidth = w;
			baseHeight = h;
		}
		
		public static function setScreen(w:int, h:int):void {
			screenWidth = w;
			screenHeight = h;
			screenRatio = w / h;
			//if (h <= 480) screenCode = "ld";
			//else 
			if (h <= 800 || mobile) screenCode = "hd";
			else screenCode = "fhd";
			
			setStage(baseWidth, screenHeight * baseWidth / screenWidth);
			scale = screenWidth / baseWidth;
		}
		
		public static function getAssetPath(url:String):String {
			return url.replace("fhd/", screenCode + "/");
		}
		
		private static function setStage(w:int, h:int):void {
			stageWidth = w;
			stageHeight = h;
			stageRectangle = new Rectangle(0, 0, w, h);
			stageCenter = new Point(w / 2, h / 2);
			stageDiagonal = Math.sqrt(w * w + h * h);
			stageHalfDiagonal = stageDiagonal / 2;
			frameRate = stage.frameRate;
			oneFrameTime = 1 / stage.frameRate;
		}
		
		public static function init():void {
			storageManager ||= new StorageManager;
			imageLibrary ||= new ImageLibraryAir;
			langManager ||= new LangManager( { lang: "en" } );
		}
		
		public static function exit():void {
			callbackManager.execute(EldEventConstant.exit);
		}
		
		public static function back():void {
			callbackManager.execute(EldEventConstant.back);
		}
		
		public static function activate():void {
			callbackManager.execute(EldEventConstant.activate);
		}
		
		public static function deactivate():void {
			callbackManager.execute(EldEventConstant.deactivate);
		}
	}

}