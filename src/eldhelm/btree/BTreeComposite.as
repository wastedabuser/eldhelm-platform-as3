package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeComposite extends BTreeNode {
		
		public var childNodes:Vector.<BTreeNode> = new Vector.<BTreeNode>;
		protected var index:int;
		
		public function BTreeComposite(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
		}
		
		override protected function parse(config:Object):void {
			if (!config.children) return;
			
			for each (var o:Object in config.children) 
				childNodes.push(BTreeFactory.createNode(o, bTree, this));
		}
		
		protected function get nextChild():BTreeNode {
			if (index >= childNodes.length) return null;
			return childNodes[index++];
		}
		
		override public function reset():void {
			if (!status && !index) return;
			super.reset();
			
			index = 0;
			var vLn:int = childNodes.length;
			for (var vi:int = 0; vi < vLn; vi++)
				childNodes[vi].reset();
		}
		
		override public function propagateStatus($status:int):void {
			super.propagateStatus($status);
			childNodes[index].propagateStatus($status);
		}
		
		override public function findRunningNodeMatching(str:String):BTreeNode {
			var chn:BTreeNode = childNodes[index];
			if (chn.running && chn.id.match(str)) return chn;
			return chn.findRunningNodeMatching(str);
		}
		
		override public function getState():Object {
			if (!status) return null;
			
			var childs:Array = [],
				state:Object = super.getState();
			state.children = childs;
			state.index = index;
			for (var vi:int = 0, vLn:int = childNodes.length; vi < vLn; vi++) {
				var chSt:Object = childNodes[vi].getState();
				if (!chSt) break;
				
				childs.push(chSt);
			}
			return state;
		}
		
		override public function setState(state:Object):void {
			if (!state) return;
			
			status = state.status;
			index = state.index;
			var childs:Array = state.children;
			for (var vi:int = 0, vLn:int = childNodes.length; vi < vLn; vi++) {
				var chSt:Object = childs[vi];
				if (!chSt) break;
				
				childNodes[vi].setState(chSt);
			}
		}
		
		override public function destroy():void {
			for each (var n:BTreeNode in childNodes)
				n.destroy();
			childNodes.length = 0;
			childNodes = null;
			super.destroy();
		}
		
	}

}