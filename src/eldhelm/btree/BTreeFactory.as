package eldhelm.btree {
	import flash.utils.getDefinitionByName;
	import eldhelm.btree.*;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeFactory {
		
		private static const BTREE_CLASSES:Array = [
			BTreeSequence, BTreeSelector, BTreeCondition, BTreeAction, BTreeEnd, 
			BTreeWait, BTreeReset, BTreeLookup, BTreeLoop, BTreeInvert, BTreeChangeStatus, BTreeParallel
		];
		
		public static function createNode(obj:Object, bTree:BTree, parent:BTreeNode = null, name:String = ""):BTreeNode {
			name ||= obj.type;
			var cls:Class = getDefinitionByName("eldhelm.btree.BTree" + name) as Class;
			return new cls(obj, bTree, parent);
		}
		
	}

}