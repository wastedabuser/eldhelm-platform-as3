package eldhelm.designer {
	import eldhelm.btree.iface.IBTreeSubject;
	import eldhelm.util.GameObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class RectangularZone extends PolylineZone implements IBTreeSubject {
		
		public function RectangularZone(config:Object = null) {
			super(config);
		}
		
		override protected function parse(config:Object):void {
			var properties:Object = config.properties;
			if (!properties) return;
			var w:int = int(properties.width),
				h:int = int(properties.height),
				x:int = int(properties.x) - w / 2, 
				y:int = int(properties.y) - h / 2;
			setPointsFromRectangle(new Rectangle(x, y, w, h));
		}
		
		public function setPointsFromRectangle(r:Rectangle):void {
			rect = r;
			points.length = 0;
			points.push(new Point(r.x, r.y), new Point(r.x + r.width, r.y), new Point(r.x + r.width, r.y + r.height), new Point(r.x, r.y + r.height));
		}
		
		override public function contains(point:Point):Boolean {
			return rect.containsPoint(point);
		}
		
		override public function inflate(distance:Number):void {
			rect.inflate(distance, distance);
			setPointsFromRectangle(rect);
		}
		
	}

}