package eldhelm.btree.iface {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public interface IBTreeActor {
		
		function doAction(action:String, subject:IBTreeSubject = null, onActionComplete:Function = null):int;
		
	}

}