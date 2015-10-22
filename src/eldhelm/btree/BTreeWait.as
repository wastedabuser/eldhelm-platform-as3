package eldhelm.btree {
	import eldhelm.util.CallLater;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeWait extends BTreeNode {
		
		private var seconds:Number = 1;
		private var running:Boolean;
		
		public function BTreeWait(config:Object, tree:BTree, parent:BTreeNode) {
			super(config, tree, parent);
			type = "Wait";
		}
		
		override protected function parse(config:Object):void {
			if (!config.properties) return;
			
			seconds = Number(config.properties.seconds);
		}
		
		override protected function update():void {
			if (running) return;
			
			CallLater.onNextFrame(setUpTimer);
			running = true;
			status = RUNNING;
		}
		
		private function setUpTimer():void {
			CallLater.callAfterInterval(seconds, onTimerComplete);
		}
		
		private function onTimerComplete():void {
			if (!bTree) return;
			status = SUCCESS;
			
			var debug:Boolean = bTree.debug;
			if (debug) trace("============= Continue traverse [Wait] ============");
			bTree.updateNode();
			if (debug) trace("============= Finish traverse =====================");
			
			running = false;
		}
		
		override public function reset():void {
			stopTimer();
			super.reset();
		}
		
		override public function propagateStatus($status:int):void {
			stopTimer();
			super.propagateStatus($status);
		}
		
		protected function stopTimer():void {
			if (!running) return;
			
			if (bTree.debug) trace("Timer canceled: " + type + " (" + id + ")");
			CallLater.remove(onTimerComplete);
			running = false;
		}
		
		override public function destroy():void {
			stopTimer();
			super.destroy();
		}
	}

}