package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeTask extends BTreeNode {
		
		protected var expressions:Vector.<BTreeExpression> = new Vector.<BTreeExpression>;
		
		public function BTreeTask(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
		}
		
		override protected function parse(config:Object):void {
			if (!config.properties) return;
			
			var list:Array = JSON.parse(config.properties.expressions) as Array;
			for each (var e:Array in list) {
				expressions.push(new BTreeExpression( {
					task: this,
					events: {
						expressionComplete: onExpressionComplete
					},
					expression: e
				}));
			}
		}
		
		protected function onExpressionComplete(expr:BTreeExpression, eStatus:int):void {
			
		}
		
		override public function destroy():void {
			for each (var e:BTreeExpression in expressions)
				e.destroy();
			expressions.length = 0;
			expressions = null;
			super.destroy();
		}
		
	}

}