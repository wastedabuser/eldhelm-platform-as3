package eldhelm.btree {
	import eldhelm.util.CallLater;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeReset extends BTreeNode {
		
		public function BTreeReset(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			
		}
		
		override protected function update():void {
			status = BTreeNode.RUNNING;
			
			CallLater.onNextFrame(onNextFrame);
		}
		
		protected function onNextFrame():void {
			if (!bTree) return;
			
			bTree.reset();
			bTree.traverse();
		}
		
	}

}