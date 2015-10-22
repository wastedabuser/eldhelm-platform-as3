package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeNode {
		
		public static const NOT_UPDATED:int = 0;
		public static const RUNNING:int = 1;
		public static const FAIL:int = 2;
		public static const SUCCESS:int = 3;
		
		protected static const STAUS_NAMES:Object = {
			0: "not updated",
			1: "running",
			2: "fail",
			3: "success"
		};
		
		public var id:String;
		public var bTree:BTree;
		public var parentNode:BTreeNode;
		public var status:int;
		public var type:String = "Node";
		
		public function BTreeNode(config:Object, tree:BTree, parent:BTreeNode) {
			id = config.id;
			bTree = tree;
			parentNode = parent;
			parse(config);
		}
		
		protected function parse(config:Object):void {
			
		}
		
		public function updateNode():int {
			log();
			update();
			endlog();
			return status;
		}
		
		protected function update():void {
			
		}
		
		public function log():void {
			if (bTree.debug) trace("Start update: " + type + " (" + id + ") " + STAUS_NAMES[status]);
		}
		
		public function endlog():void {
			if (bTree.debug) trace("Finish update: " + type + " (" + id + ") " + STAUS_NAMES[status]);
		}
		
		public function reset():void {
			status = NOT_UPDATED;
		}
		
		public function propagateStatus($status:int):void {
			status = $status;
		}
		
		public function finish($status:int = SUCCESS):void {
			if (bTree.debug) trace("Finish node: " + type + " (" + id + ") " + STAUS_NAMES[$status]);
			propagateStatus($status);
			
			var debug:Boolean = bTree.debug;
			if (debug) trace("============= Continue traverse [Finish] ==============");
			bTree.updateNode();
			if (debug) trace("============= Finish traverse =========================");
		}
		
		public function get running():Boolean {
			return status == BTreeNode.RUNNING;
		}
		
		public function findRunningNodeMatching(str:String):BTreeNode {
			return null;
		}
		
		public function getState():Object {
			if (!status) return null;
			
			return {
				id: id,
				status: status
			};
		}
		
		public function setState(state:Object):void {
			if (!state) return;
			
			status = state.status;
			if (status == RUNNING) status = NOT_UPDATED;
		}
		
		public function destroy():void {
			parentNode = null;
			bTree = null;
		}
		
	}

}