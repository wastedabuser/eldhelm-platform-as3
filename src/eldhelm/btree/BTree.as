package eldhelm.btree {
	import eldhelm.btree.iface.IBTreeActor;
	import eldhelm.constant.EldEventConstant;
	import eldhelm.util.GameObject;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTree extends GameObject {
		
		public var id:String;
		public var status:int;
		public var debug:Boolean;
		public var context:IBTreeActor;
		public var traversing:Boolean;
		
		protected var rootNode:BTreeNode;
		
		public function BTree(config:Object, cntxt:IBTreeActor = null) {
			context = cntxt;
			super(config);
			parse(config);
		}
		
		private function parse(config:Object):void {
			if (!config.children) return;
			var props:Object = config.properties;
			if (props) {
				if (props.debug) debug = Boolean(int(props.debug)) || props.debug == "true";
			}
			var rootObj:Object = config.children[0];
			if (!rootObj) return;
			
			rootNode = BTreeFactory.createNode(rootObj, this) as BTreeNode;
		}
		
		public function traverse():int {
			if (traversing || running) 
				return BTreeNode.RUNNING;
				
			if (debug) trace("========= Start traverse (" + id + ") ==========");
			updateNode();
			if (debug) trace("========= Finish traverse (" + id + ") =========");
			
			return status;
		}
		
		public function updateNode():void {
			traversing = true;
			status = rootNode.updateNode();
			traversing = false;
			
			if (status > 1) callbackManager.trigger(EldEventConstant.complete, this);
			
			if (destroyAfterTraverseCompleted) destroy();
		}
		
		public function reset():void {
			if (debug) trace("========= Start reset (" + id + ") ==========");
			status = BTreeNode.NOT_UPDATED;
			rootNode.reset();
			if (debug) trace("========= Finish reset (" + id + ") =========");
		}
		
		public function finish($status:int = BTreeNode.SUCCESS):void {
			status = $status;
			rootNode.finish($status);
		}
		
		public function get running():Boolean {
			return status == BTreeNode.RUNNING;
		}
		
		public function findRunningNodeMatching(str:String):BTreeNode {
			if (rootNode.running && rootNode.id.match(str)) return rootNode;
			return rootNode.findRunningNodeMatching(str);
		}
		
		public function getState():Object {
			return rootNode.getState();
		}
		
		public function setState(state:Object):void {
			if (!state) return;
			rootNode.setState(state);
		}
		
		protected var destroyAfterTraverseCompleted:Boolean;
		override public function destroy():void {
			if (traversing) {
				destroyAfterTraverseCompleted = true;
				return;
			}
			rootNode.destroy();
			rootNode = null;
			context = null;
			super.destroy();
		}
	}

}