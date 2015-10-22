package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeLookup extends BTreeSimple {
		
		public static var loaderFunction:Function;
		
		public function BTreeLookup(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			type = "Lookup";
		}
		
		override protected function parse(config:Object):void {
			if (!config.properties) return;
			var file:String = config.properties.file;
			if (!file) return;
			
			super.parse(loaderFunction(file));
		}
		
		override protected function update():void {
			childNode.updateNode();
			status = childNode.status;
		}
		
	}

}