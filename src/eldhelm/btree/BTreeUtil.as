package eldhelm.btree {
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeUtil {
		
		public static function booleanToStatus(val:Boolean):int {
			return val ? BTreeNode.SUCCESS : BTreeNode.FAIL;
		}
		
	}

}