package eldhelm.btree {
	
	/**
	 * ...
	 * @author ...
	 */
	public class BTreeInvert extends BTreeSimple {
		
		public function BTreeInvert(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
		}
		
		override protected function update():void {
			childNode.updateNode();
			status = childNode.status;
			if (status == SUCCESS) status = FAIL;
			else if (status == FAIL) status = SUCCESS;
		}
		
	}

}