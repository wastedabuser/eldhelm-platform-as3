package eldhelm.btree {
	
	/**
	 * ...
	 * @author ...
	 */
	public class BTreeChangeStatus extends BTreeSimple {
		
		protected var newStatus:int;
		
		public function BTreeChangeStatus(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
		}
		
		override protected function parse(config:Object):void {
			super.parse(config);
			
			if (!config.properties) return;
			
			newStatus = int(config.properties.status);
		}
		
		override protected function update():void {
			childNode.updateNode();
			status = newStatus;
		}
		
	}

}