package eldhelm.btree {
	import eldhelm.btree.iface.IBTreeSubject;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class BTreeValue implements IBTreeSubject {
		
		public var value:String;
		
		public function BTreeValue(val:String) {
			value = val;
		}
		
		[Inline]
		final public function get number():Number {
			return Number(value);
		}
		
		[Inline]
		final public function get integer():Number {
			return int(value);
		}
		
	}

}