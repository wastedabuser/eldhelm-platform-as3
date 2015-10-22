package eldhelm.btree {
	
	/**
	 * ...
	 * @author ...
	 */
	public class BTreeLoop extends BTreeSimple {
		
		private var iterations:int;
		private var index:int;
		
		public function BTreeLoop(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			type = "Loop";
		}
		
		override protected function parse(config:Object):void {
			super.parse(config);
			
			if (!config.properties) return;
			iterations = Number(config.properties.iterations);
		}
		
		override protected function update():void {
			if (status > 1) return;
			if (status == RUNNING && index >= iterations) {
				status = BTreeNode.SUCCESS;
				return;
			}
			
			while (index < iterations) {
				if (status > 0) childNode.reset();
				status = childNode.updateNode();
				index++;
				if (status == RUNNING) break;
			}
			
		}
		
		override public function log():void {
			if (bTree.debug) trace("Start update: " + type + " (" + id + ") " + STAUS_NAMES[status] + " iteration " + (index + 1) + " out of " + iterations);
		}
		
		override public function endlog():void {
			if (bTree.debug) trace("Finish update: " + type + " (" + id + ") " + STAUS_NAMES[status] + " iteration " + index + " out of " + iterations);
		}
		
		override public function reset():void {
			if (!status && !index) return;
			
			index = 0;
			super.reset();
		}
		
	}

}