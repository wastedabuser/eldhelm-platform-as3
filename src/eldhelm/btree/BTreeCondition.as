package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeCondition extends BTreeTask {
		
		public function BTreeCondition(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			type = "Condition";
		}
		
		override protected function update():void {
			status = SUCCESS;
			for each (var e:BTreeExpression in expressions) {
				if (e.evaluate() == FAIL) {
					status = FAIL;
					break;
				}
			}
		}
		
		override protected function onExpressionComplete(expr:BTreeExpression, eStatus:int):void {
			throw("BTree conditions can not have async completion");
		}
		
	}

}