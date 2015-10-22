package eldhelm.designer {
	import eldhelm.util.PlanimetryUtil;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import solar.physic.MathUtil;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class Line {
		
		public var p1:Point;
		public var p2:Point;
		
		public function Line(pt1:Point = null, pt2:Point = null) {
			p1 = pt1;
			p2 = pt2;
		}
		
		public function setPoints(pt1:Point, pt2:Point):void {
			p1 = pt1;
			p2 = pt2;
		}
		
		private var bounds:Rectangle;
		public function getBounds():Rectangle {
			if (!bounds) bounds = new Rectangle;
			bounds.x = p1.x > p2.x ? p2.x : p1.x;
			bounds.y = p1.y > p2.y ? p2.y : p1.y;
			bounds.width = Math.abs(p1.x - p2.x);
			bounds.height = Math.abs(p1.y - p2.y);
			return bounds;
		}
		
		public function crossWithLine(ln:Line, pt:Point = null):Point {
			var 
				x1:Number = p1.x,
				x2:Number = p2.x,
				y1:Number = p1.y,
				y2:Number = p2.y,
				
				x3:Number = ln.p1.x,
				x4:Number = ln.p2.x,
				y3:Number = ln.p1.y,
				y4:Number = ln.p2.y;
			
			var bp:Number = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
			if (bp == 0) return null;
			
			if (!pt) pt = new Point;
			var a:Number = (x1 * y2 - y1 * x2),
				b:Number = (x3 * y4 - y3 * x4);
			pt.x = (a * (x3 - x4) - (x1 - x2) * b) / bp;
			pt.y = (a * (y3 - y4) - (y1 - y2) * b) / bp;
			
			if (getBounds().containsPoint(pt) && ln.getBounds().containsPoint(pt)) return pt;
			return null;
		}
		
		public function copy():Line {
			return new Line(p1, p2);
		}
		
		public function destroy():void {
			p1 = null;
			p2 = null;
		}
		
	}

}