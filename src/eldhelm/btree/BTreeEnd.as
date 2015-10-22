package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeEnd extends BTreeNode {
		
		public function BTreeEnd(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			type = "End";
		}
		
		override protected function parse(config:Object):void {
			if (!config.properties) return;
			
			status = int(config.properties.status);
		}
		
	}

}