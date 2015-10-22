package eldhelm.bundle {
	import eldhelm.manager.ImageLibrary;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class ImageLibraryBundle extends ImageLibrary {
		
		public function ImageLibraryBundle() {
			super();
			assetLoader.dirPrefix = "app://";
		}
	
	}

}