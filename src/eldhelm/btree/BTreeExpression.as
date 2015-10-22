package eldhelm.btree {
	import eldhelm.btree.iface.IBTreeActor;
	import eldhelm.btree.iface.IBTreeSubject;
	import eldhelm.util.GameObject;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeExpression extends GameObject {
		
		public static const EXPRESSION_COMPLETE:String = "expressionComplete";
		public var task:BTreeTask;
		
		protected var who:String;
		protected var does:String;
		protected var what:String;
		protected var whoActor:IBTreeActor;
		protected var whatSubject:IBTreeSubject;
		
		public function BTreeExpression(config:Object) {
			super(config);
			who = config.expression[0];
			does = config.expression[1];
			what = config.expression[2];
		}
		
		public function evaluate():int {
			if (!whoActor) {
				if (who) whoActor = BTreeBlackboard.getActorById(who);
				else whoActor = task.bTree.context;
				
				if (!whoActor) {
					trace("Expression actor " + who + " is not found!");
					return BTreeNode.FAIL;
				}
				if (what) whatSubject = BTreeBlackboard.getSubjectById(what);
			}
			return whoActor.doAction(does, whatSubject, onActionComplete);
		}
		
		protected function onActionComplete(status:int, ... rest:Array):void {
			if (!callbackManager) return;
			callbackManager.trigger(EXPRESSION_COMPLETE, this, status);
		}
		
		override public function destroy():void {
			task = null;
			whoActor = null;
			whatSubject = null;
			super.destroy();
		}
		
	}

}