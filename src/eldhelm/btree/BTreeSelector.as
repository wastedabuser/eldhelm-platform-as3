package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeSelector extends BTreeComposite {
		
		public function BTreeSelector(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			type = "Selector";
		}
		
		override protected function update():void {
			if (status > 1) return;
			
			while (1) {
				var ch:BTreeNode = nextChild;
				if (!ch) break;
				
				status = ch.updateNode();
				if (status == SUCCESS || status == RUNNING) break;
			}
			
			if (status == RUNNING) index--;
			else index = 0;
		}
		
	}

}