package eldhelm.input {
	import eldhelm.manager.AppManager;
	import eldhelm.util.CallbackManager;
	import flash.events.Event;
	import flash.events.GameInputEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import solar.constant.EventConstant;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class GameInputManager {
		
		public static var callbackManager:CallbackManager;
		public static var hasGameController:Boolean;
		public static var firstControllerCode:String;
		
		private static var gameInput:GameInput;		
		private static var mappings:Object = {};
		private static var devices:Dictionary = new Dictionary;
		private static var deviceMapping:Object = {};
		private static var values:Object = { };
		
		public static function init():void {
			callbackManager = new CallbackManager;
			
			if (GameInput.isSupported) {
				gameInput = new GameInput;
				gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onDeviceAdded);
				gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
			}
			
			if (Keyboard.isAccessible) {
				AppManager.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardKeyUp);
				AppManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardKeyDown);
			}
		}
		
		protected static function onDeviceAdded(event:GameInputEvent):void {
			var device:GameInputDevice = event.device,
				mapping:GameInputMapping;
			
			for each (var m:GameInputMapping in mappings) {
				if (m.match(device)) {
					deviceMapping[device.id] = m;
					break;
				}
			}
			
			mapping = deviceMapping[device.id];
			if (!mapping) return;
			
			devices[device] = device.id;
			device.enabled = true;
			device.sampleInterval = int(1000 / AppManager.frameRate);
			
			var len:int = device.numControls,
				vec:Vector.<String> = new Vector.<String>();
				
			for (var i:int = 0; i < len; i++) {
				var ctrl:GameInputControl = device.getControlAt(i);
				vec.push(ctrl.id);
				ctrl.addEventListener(Event.CHANGE, onControlChanged);
			}
			
			device.startCachingSamples(10, vec);
			
			if (!hasGameController && mapping.isGameController) {
				hasGameController = mapping.isGameController;
				firstControllerCode = mapping.code;
			}
		}
		
		protected static function onControlChanged(event:Event):void {
			var ctrl:GameInputControl = event.target as GameInputControl,
				mapping:GameInputMapping = deviceMapping[ctrl.device.id];
			
			if (!mapping) return;
			
			var ctrlMap:Object = mapping.controls[ctrl.id];
			if (!ctrlMap) return;
			
			var value:Number = ctrl.value,
				code:String = ctrlMap[value];
			if (code) {
				inputCommand(code, value);
				return;
			}
			
			code = ctrlMap.analog;
			value = ctrlMap.invert ? -value : value;
			if (Math.abs(value) < .01) value = 0;
			if (code) inputCommand(code, value);
		}
		
		protected static function onDeviceRemoved(event:GameInputEvent):void {
			var device:GameInputDevice = event.device,
				mapping:GameInputMapping = deviceMapping[devices[device]];
				
			//device.stopCachingSamples();
			device.enabled = false;
			delete devices[device];
			
			var len:int = device.numControls;
			for (var i:int = 0; i < len; i++) {
				var ctrl:GameInputControl = device.getControlAt(i);
				ctrl.removeEventListener(Event.CHANGE, onControlChanged);
			}
			
			if (mappings && mapping.code == firstControllerCode) {
				firstControllerCode = "";
				hasGameController = false;
			}
		}
		
		protected static function onKeyboardKeyUp(event:KeyboardEvent):void {
			keyboardKeyChange(event.keyCode, 0);
		}
		
		protected static function onKeyboardKeyDown(event:KeyboardEvent):void {
			keyboardKeyChange(event.keyCode, 1);
		}
		
		protected static function keyboardKeyChange(keyCode:int, value:int):void {
			var mapping:GameInputMapping = mappings.keyboard;
			if (!mapping) return;
			
			var ctrlMap:Object = mapping.controls[keyCode];
			if (!ctrlMap) return;
			
			var code:String = ctrlMap[value];
			if (code) inputCommand(code, value);
			
			code = ctrlMap.analog;
			if (code) inputCommand(code, value ? ctrlMap.value : 0);
		}
		
		public static function addMapping(mapping:GameInputMapping):void {
			mappings[mapping.code] = mapping;
		}
		
		public static function inputCommand(code:String, value:Number = 0):void {
			//trace(code);
			//trace(value);
			
			values[code] = value;
			callbackManager.trigger(code, value);
		}
		
		private static var eventSetsRepo:Object = { };
		public static function bind(code:String, events:Object):void {
			remove(code);
			eventSetsRepo[code] = events;
			callbackManager.events = events;
		}
		
		public static function remove(code:String):void {
			var events:Object = eventSetsRepo[code];
			if (!events) return;
			callbackManager.execute(EventConstant.remove_ + code);
			callbackManager.removeMultiple(events);
		}
		
		public static function getValue(code:String):Number {
			return values[code] || 0;
		}
		
	}

}