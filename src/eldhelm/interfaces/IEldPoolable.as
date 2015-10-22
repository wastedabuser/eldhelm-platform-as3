package eldhelm.interfaces {
	import eldhelm.util.ObjectPool;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public interface IEldPoolable {
		
		function set objectPool(pool:ObjectPool):void;
		
		/**
		 * Called when an object is taken from the pool for reuse
		 * @param config
		 */
		function getPoolObject(config:Object):void;
		
		/**
		 * Called when an object is marked as available for reuse
		 */
		function freePoolObject():void;
		
		/**
		 * The object will never be use again
		 */
		function destroy():void;
		
	}
	
}