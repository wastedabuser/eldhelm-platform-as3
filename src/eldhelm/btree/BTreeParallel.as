package eldhelm.btree {
	/**
	 * ...
	 * @author ...
	 */
	public class BTreeParallel extends BTreeNode {
		
		public var childNodes:Vector.<BTreeNode> = new Vector.<BTreeNode>;
		
		public function BTreeParallel(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			type = "Parallel";
		}
		
		override protected function parse(config:Object):void {
			if (!config.children) return;
			
			for each (var o:Object in config.children) 
				childNodes.push(BTreeFactory.createNode(o, bTree, this));
		}
		
		override protected function update():void {
			if (status > 1) return;
			
			status = NOT_UPDATED;
			for (var vi:int = 0, vLn:int = childNodes.length; vi < vLn; vi++) {
				var ch:BTreeNode = childNodes[vi];
				var st:int = ch.updateNode();
				
				if (st == RUNNING || status == NOT_UPDATED) status = st;
				else if (status != RUNNING)
					status = int(Boolean(st - 2) && Boolean(status - 2)) + 2;
			}
		}
		
		override public function reset():void {
			if (!status) return;
			super.reset();
			
			for (var vi:int = 0, vLn:int = childNodes.length; vi < vLn; vi++)
				childNodes[vi].reset();
		}
		
		override public function propagateStatus($status:int):void {
			super.propagateStatus($status);
			
			for (var vi:int = 0, vLn:int = childNodes.length; vi < vLn; vi++)
				childNodes[vi].propagateStatus($status);
		}
		
		override public function findRunningNodeMatching(str:String):BTreeNode {
			for (var vi:int = 0, vLn:int = childNodes.length; vi < vLn; vi++) {
				var chn:BTreeNode = childNodes[vi];
				if (chn.running && chn.id.match(str)) return chn;
				
				var res:BTreeNode = chn.findRunningNodeMatching(str);
				if (res) return res;
			}
			return null;
		}
		
		override public function getState():Object {
			var childs:Array = [],
				state:Object = super.getState();
			state.children = childs;
			for (var vi:int = 0, vLn:int = childNodes.length; vi < vLn; vi++) {
				childs.push(childNodes[vi].getState());
			}
			return state;
		}
		
		override public function setState(state:Object):void {
			if (!state) return;
			
			status = state.status;
			var childs:Array = state.children;
			for (var vi:int = 0, vLn:int = childNodes.length; vi < vLn; vi++) {
				childNodes[vi].setState(childs[vi]);
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