package eldhelm.btree {
	
	/**
	 * ...
	 * @author ...
	 */
	public class BTreeSimple extends BTreeNode {
		
		public var childNode:BTreeNode;
		
		public function BTreeSimple(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
		}
		
		override protected function parse(config:Object):void {
			if (!config.children) return;
			var rootObj:Object = config.children[0];
			if (!rootObj) return;
			
			childNode = BTreeFactory.createNode(rootObj, bTree, this);
		}
		
		override public function reset():void {
			if (childNode)
				childNode.reset();
			super.reset();
		}
		
		override public function propagateStatus($status:int):void {
			super.propagateStatus($status);
			if (childNode)
				childNode.propagateStatus($status);
		}
		
		override public function findRunningNodeMatching(str:String):BTreeNode {
			if (!childNode) return null;
			if (childNode.running && childNode.id.match(str)) return childNode;
			return childNode.findRunningNodeMatching(str);
		}
		
		override public function getState():Object {
			if (!status) return null;
			
			var state:Object = super.getState();
			if (childNode)
				state.child = childNode.getState();
			
			return state;
		}
		
		override public function setState(state:Object):void {
			if (!state) return;
			
			status = state.status;
			if (childNode && state.child)
				childNode.setState(state.child);
		}
		
		override public function destroy():void {
			if (childNode) {
				childNode.destroy();
				childNode = null;
			}
			super.destroy();
		}
		
	}

}