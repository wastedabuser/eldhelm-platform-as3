package eldhelm.bundle {
	import eldhelm.manager.SoundManager;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class SoundManagerBundle extends SoundManager {
		
		public function SoundManagerBundle() {
			super();
			assetLoader.dirPrefix = "app://";
		}
	
	}

}