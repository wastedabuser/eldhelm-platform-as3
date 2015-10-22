package eldhelm.manager {
	import eldhelm.event.RpcEvent;
	import eldhelm.manager.AssetLibrary;
	import eldhelm.util.CallLater;
	import eldhelm.util.ObjectUtil;
	import eldhelm.util.Playlist;
	import eldhelm.util.Rpc;
	import eldhelm.network.LoaderPoolSound;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class SoundManager extends AssetLibrary {
		
		public static var soundsSuppresed:Boolean;
		
		public static function playSound(url:String):SoundChannel {
			if (soundsSuppresed) return null;
			
			var snd:SoundManager = AppManager.soundManager;
			if (snd == null) return null;
			if (snd.disabled) return null;
			if (snd.hasSound(url)) return snd.getSound(url).play(0, 0, snd.transform);
			return null;
		}
		
		protected static var playingNotifications:Object = { };
		public static function playNotification(url:String):SoundChannel {
			var snd:SoundManager = AppManager.soundManager;
			if (snd.muteNotifications) return null;
			
			if (playingNotifications[url]) return null;
			var sndc:SoundChannel = playSound(url);
			if (sndc) {
				playingNotifications[url] = true;
				new CallLater().afterDelay(1, notificationTimeout, [url]);
			}
			
			return sndc;
		}
		
		protected static function notificationTimeout(url:String):void {
			delete playingNotifications[url];
		}
		
		public var transform:SoundTransform;
		protected var playlists:Object = {};
		protected var _volume:int = 5;
		protected var _mute:Boolean;
		protected var _muteNotifications:Boolean;
		
		public function SoundManager() {
			super();
			assetLoader = new LoaderPoolSound( {
				success: onAllLoaderSuccess,
				itemSuccess: onItemLoaderSuccess,
				itemError: onItemLoaderError
			});
			transform = new SoundTransform;
		}
		
		public function set volume(val:int):void {
			_volume = val;
			applyVolume();
		}
		
		public function set muteNotifications(state:Boolean):void {
			_muteNotifications = state;
		}
		
		public function set mute(state:Boolean):void {
			_mute = state;
			applyVolume();
		}
		
		public function get volume():int {
			return _volume;
		}
		
		public function get muteNotifications():Boolean {
			return _muteNotifications;
		}
		
		public function get mute():Boolean {
			return _mute;
		}
		
		public function get disabled():Boolean {
			return mute || volume < 0;
		}
		
		protected function applyVolume():void {
			transform.volume = _volume / 10 * int(!_mute);
		}		
		
		public function getPlaylist(name:String, callback:Function):void {
			if (!playlists[name]) {
				Rpc.execute( {
					procedure: "sound.getPlaylist",
					params: {
						name: name
					},
					complete: function(event:RpcEvent):void {
						var plist:Playlist = new Playlist(event.data);
						playlists[plist.name] = plist;
						if (callback != null) callback(plist);
					}
				});
			} else {
				callback(playlists[name]);
			}
		}
		
		public function loadTracklist(name:String):void {
			getPlaylist(name, loadPlaylistTracks);
		}
		
		protected function loadPlaylistTracks(playlist:Playlist):void {
			loadMore(playlist.tracks);
		}
		
		public function getSound(url:String):Sound {
			return library[url] is Sound ? library[url] : null;
		}
		
		public function hasSound(url:String):Boolean {
			return library[url] is Sound;
		}
		
		override public function destroy():void {
			ObjectUtil.emptyObject(playlists);
			playlists = null;
			transform = null;
			super.destroy();
		}
		
	}

}