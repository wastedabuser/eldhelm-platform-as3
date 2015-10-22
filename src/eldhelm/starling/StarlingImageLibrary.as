package eldhelm.starling {
	import eldhelm.manager.AppManager;
	import eldhelm.util.CallbackManager;
	import eldhelm.util.ObjectUtil;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import solar.asset.ObjectResources;
	import solar.constant.EventConstant;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class StarlingImageLibrary {
		
		public static var callbackManager:CallbackManager = new CallbackManager;
		
		private static var _textureCache:Object = { };
		private static var _textureMeta:Object = { };
		private static var _atlasXml:Object = { };
		private static var _atlasTextureUrl:Object = { };
		private static var zeroPt:Point = new Point;
		
		public static function loadTextureImages(list:Array, callback:Function):Array {
			var images:Array = [];
			for (var i:int = 0, l:int = list.length; i < l; i++) {
				var url:String = AppManager.getAssetPath(list[i]);
				
				if (url.indexOf(";") >= 0) url = url.split(";")[0];
				if (url.indexOf(".xml") >= 0) url = getAtlasImage(url);
				
				var meta:Object = getTextureMeta(url);
				if (meta.color) url = meta.mask;
				else if (meta.mask) images.push(meta.mask);
				
				images.push(url);
			}
			AppManager.imageLibrary.loadMore(images, callback);
			return images;
		}
		
		public static function createTexture(url:String):void {
			if (url.indexOf(";") >= 0) {
				getTextureAtlas(url.split(";")[0]);
				return;
			}
			if (url.indexOf(".xml") >= 0) {
				getTextureAtlas(url);
				return;
			}
			getTexture(url);
		}
		
		public static function clearAllTexturesExcept(list:Array, ...rest:Array):void {
			if (!list) return;
			
			var lkp:Object = normalizeAssetList(rest, normalizeAssetList(list)),
				rmv:Array = [];
			for (var i:String in _textureCache) {
				if (!lkp[i]) rmv.push(i);
			}
			
			clearTextureList(rmv);
		}
		
		public static function normalizeAssetList(list:Array, lkp:Object = null):Object {
			if (!lkp) lkp = { };
			for (var i:int = 0, l:int = list.length; i < l; i++) {
				var url:String = list[i];
				if (url.indexOf(";") >= 0) url = url.split(";")[0];
				lkp[url] = url;
				var aUrl:String = _atlasTextureUrl[url];
				if (aUrl) lkp[aUrl] = aUrl;
			}
			return lkp;
		}
		
		public static function filterMissing(list:Array):Array {
			var missing:Array = [];
			list = ObjectUtil.makeArray(normalizeAssetList(list));
			for (var i:int = 0, l:int = list.length; i < l; i++) {
				var str:String = list[i];
				if (hasTexture(str)) continue;
				
				missing.push(str);
			}
			return missing;
		}
		
		private static function getTextureMeta(url:String):Object {
			if (_textureMeta[url]) return _textureMeta[url];
			
			var aurl:String = AppManager.getAssetPath(url),
				cls:Class = ObjectResources.assetMap[aurl.replace(/\.[^\.]+/, ".json")], 
				metaData:Object;
			
			if (cls) {
				var txt:ByteArray = new cls as ByteArray;
				metaData = JSON.parse(txt.toString());
				if (metaData.mask) metaData.mask = aurl.replace(/\/[^\/]+$/, "/" + metaData.mask);
			} else {
				metaData = { };
			}
			
			return _textureMeta[url] = metaData;
		}
		
		public static function getTexture(url:String):Texture {
			if (_textureCache[url]) return _textureCache[url];
			
			var aurl:String = AppManager.getAssetPath(url),
				metaData:Object = getTextureMeta(url),
				data:BitmapData;
			
			if (metaData.mask) {
				var maskData:BitmapData = AppManager.imageLibrary.getBitmapDataRef(metaData.mask);
				if (maskData) {
					
					if (metaData.color) data = new BitmapData(maskData.width, maskData.height, false, uint(metaData.color));
					else data = AppManager.imageLibrary.getBitmapDataRef(aurl);
					
					var mergedData:BitmapData = new BitmapData(data.width, data.height, true, 0);
					mergedData.copyChannel(maskData, maskData.rect, zeroPt, BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);
					mergedData.merge(data, data.rect, zeroPt, 255, 255, 255, 0);
					
					if (metaData.color) data.dispose();
					
					data = mergedData;
				} else {
					throw("No mask bitmap data for " + aurl);
				}
			} else {
				data = AppManager.imageLibrary.getBitmapDataRef(aurl);
			}
			
			return _textureCache[url] = Texture.fromBitmapData(data, false);
		}
		
		private static function getAtlasXml(url:String):XML {
			if (_atlasXml[url]) return _atlasXml[url];
			
			var aurl:String = AppManager.getAssetPath(url),
				cls:Class = ObjectResources.assetMap[aurl];
			if (!cls) throw("The atlas " + aurl + " has no xml description");
			
			return _atlasXml[url] = XML(new cls); 
		}
		
		private static function getAtlasImage(url:String):String {
			if (_atlasTextureUrl[url]) return _atlasTextureUrl[url];
			
			var aurl:String = AppManager.getAssetPath(url),
				texturePath:String = getAtlasXml(url).attribute("imagePath");
			if (!texturePath) throw("can not find texture");
			
			texturePath = aurl.replace(/[^\/]+$/, texturePath);
			return _atlasTextureUrl[url] = texturePath;
		}
		
		public static function getTextureAtlas(url:String):TextureAtlas {
			if (_textureCache[url]) return _textureCache[url];
			
			return _textureCache[url] = new TextureAtlas(getTexture(getAtlasImage(url)), getAtlasXml(url));
		}
		
		public static function getTextureFromAtlas(atlas:String, texture:String):Texture {
			return getTextureAtlas(atlas).getTexture(texture);
		}
		
		public static function getTextureFromAtlas2(texture:String):Texture {
			if (texture.indexOf(";") >= 0) {
				var parts:Array = texture.split(";");
				return getTextureAtlas(parts[0]).getTexture(parts[1]);
			}
			return getTexture(texture);
		}
		
		public static function hasTexture(url:String):Boolean {
			return _textureCache[url] is Texture || _textureCache[url] is TextureAtlas;
		}
		
		public static function clearTextures():void {
			var list:Array = [];
			for (var i:String in _textureCache) {
				list.push(i);
			}
			clearTextureList(list);
		}
		
		public static function clearTextureList(list:Array):void {
			for each (var i:String in list) {
				if (i.indexOf(";") > 0) {
					removeTextureAtlas(i.split(";")[0]);
					continue;
				}
				removeTexture(i);
			}
		}
		
		protected static function removeTexture(nm:String):void {
			if (!_textureCache[nm]) return;
			
			var meta:Object = getTextureMeta(nm);
			if (meta.mask) AppManager.imageLibrary.removeData(meta.mask);
			
			_textureCache[nm].dispose();
			delete _textureCache[nm];
			
			AppManager.imageLibrary.removeData(nm);
			
			callbackManager.trigger(nm);
		}
		
		protected static function removeTextureAtlas(nm:String):void {
			if (!_textureCache[nm]) return;
			
			_textureCache[nm].dispose();
			delete _textureCache[nm];
			
			removeTexture(_atlasTextureUrl[nm]);
		}
		
		public static function bindTextureDispose(url:String, callback:Function):void {
			if (url.indexOf(";") >= 0) url = url.split(";")[0];
			
			callbackManager.bind(url, callback);
		}
		
		public static function unbindTextureDispose(url:String, callback:Function):void {
			if (url.indexOf(";") >= 0) url = url.split(";")[0];
			
			callbackManager.remove(url, callback);
		}
		
	}

}