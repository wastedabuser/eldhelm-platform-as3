package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeSequence extends BTreeComposite {
		
		public function BTreeSequence(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			type = "Sequence";
		}
		
		override protected function update():void {
			if (status > 1) return;
			
			while (1) {
				var ch:BTreeNode = nextChild;
				if (!ch) break;
				
				status = ch.updateNode();
				if (status == FAIL || status == RUNNING) break;
			}
			
			if (status == RUNNING) index--;
			else index = 0;
		}
		
	}

}