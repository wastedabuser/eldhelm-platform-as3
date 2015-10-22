package eldhelm.embed {
	import eldhelm.asset.SoundResources;
	import eldhelm.manager.SoundManager;
	import flash.media.Sound;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class SoundManagerEmbedded extends SoundManager {
		
		public function SoundManagerEmbedded() {
			super();
		}
		
		override public function getSound(url:String):Sound {
			var cls:Class = SoundResources.assetMap[url];
			if (cls != null) {
				return new cls;
			}
			return super.getSound(url);
		}
		
	}

}