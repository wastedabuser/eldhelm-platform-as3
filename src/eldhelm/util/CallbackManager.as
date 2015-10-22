package eldhelm.util {
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CallbackManager {
		
		private var callbackRepo:Object = {};
		private var callbackRepoMap:Object = {};
		
		public function CallbackManager(config:Object = null){
			if (config != null) {
				if (config.callbacks && config.callbacks != null) callbacks = config.callbacks;
				if (config.events && config.events != null) events = config.events;
			}
		}
		
		public function set callbacks(cbks:Object):void {
			if (cbks == null) return;
			for (var i:String in cbks) {
				var it:* = cbks[i];
				if (it is Function) {
					if (it == null) throw("Property " + i + " is not a function");
					one(i, cbks[i]);
				} else if (it is Array) {
					var ls:Array = it.concat();
					one(i, ls.shift(), ls);
				}
			}
		}
		
		public function set events(cbks:Object):void {
			if (cbks == null) return;
			for (var i:String in cbks) {
				var it:* = cbks[i];
				if (it is Function) {
					if (it == null) throw("Property " + i + " is not a function");
					bind(i, cbks[i]);
				} else if (it is Array) {
					var ls:Array = it.concat();
					bind(i, ls.shift(), ls);
				}
			}
		}
		
		public function bind(name:String, callback:Function, args:Array = null):void {
			add(name, callback, args, false);
		}
		
		public function one(name:String, callback:Function, args:Array = null):void {
			add(name, callback, args, true);
		}
		
		public function add(name:String, callback:Function, args:Array = null, one:Boolean = true):void {
			if (!callbackRepo[name]) callbackRepo[name] = new Vector.<Array>;
			if (!callbackRepoMap[name]) callbackRepoMap[name] = new Dictionary;
			var callbackObject:Array = [callback, args, one];
			callbackRepo[name].push(callbackObject);
			callbackRepoMap[name][callback] = callbackObject;
		}
		
		private var executeLists:Vector.<Vector.<Array>> = new Vector.<Vector.<Array>>;
		public function execute(name:String, args:Array = null):void {
			var list:Vector.<Array> = callbackRepo[name];
			if (!list) return;
			
			var executeList:Vector.<Array> = executeLists.pop();
			if (!executeList) executeList = new Vector.<Array>;
			for (var i:int = 0, l:int = list.length; i < l; i++) {
				executeList.push(list[i]);
			}
			
			var cbk:Array,
				fn:Function,
				params:Array;
			for (i = 0, l = executeList.length; i < l; i++) {
				cbk = executeList[i];
				fn = cbk[0];
				params = cbk[1];
				
				if (params) {
					if (args) params = params.concat(args);
				} else {
					params = args;
				}
				
				if (params) fn.apply(null, params);
				else fn();
				
				if (cbk[2]) remove(name, fn);
			}
			
			executeList.length = 0;
			if (executeLists) executeLists.push(executeList);
		}
		
		private var triggerArgs:Vector.<Array> = new Vector.<Array>;
		public function trigger(name:String, arg1:* = undefined, arg2:* = undefined, arg3:* = undefined, arg4:* = undefined):void {
			var args:Array; 
			if (arg1 !== undefined) {
				args = triggerArgs.pop() || [];
				args.push(arg1);
				if (arg2 !== undefined) {
					args.push(arg2);
					if (arg3 !== undefined) {
						args.push(arg3);
						if (arg4 !== undefined) {
							args.push(arg4);
						}
					}
				}
			}
			execute(name, args);
			if (args && triggerArgs) {
				args.length = 0;
				triggerArgs.push(args);
			}
		}
		
		public function has(name:String, callback:Function = null):Boolean {
			if (!callbackRepo) return false;
			
			if (callback != null) {
				if (!callbackRepoMap[name]) return false;
				if (callbackRepoMap[name][callback]) return true;
			} else if (callbackRepo[name]) 
				return true;
				
			return false;
		}
		
		public function remove(name:String, callback:Function = null):void {
			if (!callbackRepo) return;
			var list:Vector.<Array> = callbackRepo[name];
			if (!list) return;
			
			if (callback != null) {
				var cbObj:Array = callbackRepoMap[name][callback];
				delete callbackRepoMap[name][callback];
				var index:int = list.indexOf(cbObj);
				if (index >= 0) list.splice(index, 1);
			} else {
				ObjectUtil.emptyObject(callbackRepoMap[name]);
				while (list.length > 0) list.shift().length = 0;
			}
		}
		
		public function removeAll():void {
			for (var i:String in callbackRepo) remove(i);
		}
		
		public function removeMultiple(eventSet:Object):void {
			for (var i:String in eventSet) {
				remove(i, eventSet[i]);
			}
		}
		
		public function destroy():void {
			removeAll();
			callbackRepo = null;
			callbackRepoMap = null;
			executeLists.length = 0;
			executeLists = null;
			triggerArgs.length = 0;
			triggerArgs = null;
		}
		
	}
}