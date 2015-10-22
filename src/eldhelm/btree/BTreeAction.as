package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeAction extends BTreeTask {
		
		private var success:int;
		private var fail:int;
		
		public function BTreeAction(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			type = "Action";
		}
		
		override protected function update():void {
			if (status > 0) return;
			status = RUNNING;
			
			var vLn:int = expressions.length;
			for (var vi:int = 0; vi < vLn; vi++) {
				readExpressionStataus(expressions[vi].evaluate());
			}
			
			updateTaskStatus();
			if (status != RUNNING) {
				success = 0;
				fail = 0;
			}
		}
		
		private function readExpressionStataus(st:int):void {
			if (st == SUCCESS) success++;
			else if (st == FAIL) fail++;
		}
		
		private function updateTaskStatus():void {
			if (!expressions) return;
			
			if (expressions.length == success) status = SUCCESS;
			else if (fail > 0 && expressions.length == success + fail) status = FAIL;
		}
		
		override protected function onExpressionComplete(expr:BTreeExpression, eStatus:int):void {
			readExpressionStataus(eStatus);
			updateTaskStatus();
			
			if (status == RUNNING) return;
			success = 0;
			fail = 0;
			
			var debug:Boolean = bTree.debug;
			if (debug) trace("============= Continue traverse [Action] ==============");
			bTree.updateNode();
			if (debug) trace("============= Finish traverse =========================");
		}
		
		override public function reset():void {
			success = 0;
			fail = 0;
			super.reset();
		}
		
		override public function propagateStatus($status:int):void {
			success = 0;
			fail = 0;
			super.propagateStatus($status);
		}
		
	}

}