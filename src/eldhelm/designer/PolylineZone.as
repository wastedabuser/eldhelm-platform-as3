package eldhelm.designer {
	import eldhelm.btree.iface.IBTreeSubject;
	import eldhelm.util.GameObject;
	import eldhelm.util.PlanimetryUtil;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import solar.physic.MathUtil;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class PolylineZone extends GameObject implements IBTreeSubject {
		
		public var id:String;
		public var points:Vector.<Point> = new Vector.<Point>;
		protected var rect:Rectangle;
		
		public function PolylineZone(config:Object = null) {
			super(config);
			if (config) parse(config);
		}
		
		protected function parse(config:Object):void {
			if (!config.properties) return;
			
			var pts:Array = JSON.parse(config.properties.lineCoordinates) as Array,
				ox:Number = config.offsetX || 0,
				oy:Number = config.offsetY || 0;
			
			for each (var pt:Array in pts) {
				points.push(new Point(pt[0] - ox, pt[1] - oy));
			}
			
			updateBoundingRectangle();
		}
		
		public function setPoints(pts:Vector.<Point>, clone:Boolean = false):void {
			points.length = 0;
			if (clone) copyPoints(pts);
			else putPoints(pts);
			updateBoundingRectangle();
		}
		
		public function putPoints(pts:Vector.<Point>):void {
			for (var i:int = 0, l:int = pts.length; i < l; i++) {
				points[i] = pts[i];
			}
		}
		
		public function copyPoints(pts:Vector.<Point>):void {
			for (var i:int = 0, l:int = pts.length; i < l; i++) {
				if (points.length <= i) points[i] = pts[i].clone();
				points[i].copyFrom(pts[i]);
			}
		}
		
		public function get length():int {
			return points.length;
		}
		
		public function get first():Point {
			return points[0];
		}
		
		public function get direction():Number {
			if (points.length < 2) return 0;
			return PlanimetryUtil.getDirectionBetweenPoints(points[0], points[1]);
		}
		
		public function clear():void {
			points.length = 0;
		}
		
		private var _medianPoint:Point = new Point;
		public function get medianPoint():Point {
			return MathUtil.calculateMedian(points, _medianPoint); 
		}
		
		protected function updateBoundingRectangle():void {
			if (!rect) rect = new Rectangle;
			var rl:Number = Number.POSITIVE_INFINITY,
				rt:Number = Number.POSITIVE_INFINITY,
				rr:Number = Number.NEGATIVE_INFINITY,
				rb:Number = Number.NEGATIVE_INFINITY;
			for (var i:int = 0, l:int = points.length; i < l; i++) {
				var point:Point = points[i];
				rl = Math.min(point.x, rl);
				rt = Math.min(point.y, rt);
				rr = Math.max(point.x, rr);
				rb = Math.max(point.y, rb);
			}
			rect.left = rl;
			rect.top = rt;
			rect.right = rr;
			rect.bottom = rb;
		}
		
		public function contains(p:Point):Boolean {
			if (!points) return false;
			
			var n:int = points.length,
				j:int, v1:Point, v2:Point, count:int;
			for (var i:int = 0; i < n; i++) {
				j = i + 1 == n ? 0: i + 1;
				v1 = points[i];
				v2 = points[j];
				if (isLeft(p,v1,v2)) {
					if ((p.y > v1.y && p.y <= v2.y) || (p.y > v2.y && p.y <= v1.y)) {
						count++;
					}
				}
			}
			return count % 2 != 0;
		}
		
		protected function isLeft(p:Point, v1:Point, v2:Point):Boolean {
			if (v1.x == v2.x) {
				return p.x <= v1.x;
			}
			
			var m:Number = (v2.y - v1.y) / (v2.x - v1.x);
			var x2:Number = (p.y - v1.y) / m + v1.x;
			return p.x <= x2;
		}
		
		public function notContains(point:Point):Boolean {
			return !contains(point);
		}
		
		public function getLines():Vector.<Line> {
			var lines:Vector.<Line> = new Vector.<Line>;
			for (var i:int = 1, l:int = points.length; i < l; i++) {
				lines.push(new Line(points[i - 1], points[i]));
			}
			lines.push(new Line(points[i - 1], points[0]));
			return lines;
		}
		
		private var testTr:PolylineZone;
		private var testLine:Line;
		private var testPoint:Point;
		public var triangles:Vector.<PolylineZone>;
		public function triangulate():void {
			if (!triangles) triangles = new Vector.<PolylineZone>;
			else removeTriangles();
			if (!testTr) testTr = new PolylineZone;
			if (!testLine) testLine = new Line;
			if (!testPoint) testPoint = new Point;
			var pts:Vector.<Point> = points.concat(),
				lines:Vector.<Line> = getLines(),
				l:int = lines.length,
				i:int;
			while (pts.length >= 3) {
				var i1:int = i + 1, 
					i2:int = i + 2,
					pln:int = pts.length;
				if (i1 >= pln) i1 -= pln;
				if (i2 >= pln) i2 -= pln;
				
				testTr.clear();
				testTr.points.push(pts[i], pts[i1], pts[i2]);
				if (contains(testTr.medianPoint)) {
					testLine.setPoints(pts[i], pts[i2]);
					var valid:Boolean = true;
					for (var z:int = 0; z < l; z++) {
						var ln:Line = lines[z];
						if (testLine.p1 == ln.p1 || testLine.p2 == ln.p2 || testLine.p1 == ln.p2 || testLine.p2 == ln.p1) continue;
						if (testLine.crossWithLine(ln, testPoint)) {
							valid = false;
							break;
						}
					}
					if (valid) {
						triangles.push(testTr.copy());
						lines.push(testLine.copy());
						pts.splice(i1, 1);
					}
				}
				i++;
				if (i > pts.length - 1) i = 0;
			}
		}
		
		private function removeTriangles():void {
			for (var i:int = 0, l:int = triangles.length; i < l; i++) {
				triangles[i].destroy();
			}
			triangles.length = 0;
		}
		
		public var randomPt:Point = new Point;
		public function randomPoint():Point {
			do {
				randomPt.x = MathUtil.random(rect.left, rect.right);
				randomPt.y = MathUtil.random(rect.top, rect.bottom);
			} while (!contains(randomPt));
			return randomPt;
		}
		
		public function clone():PolylineZone {
			var clonedPoints:Vector.<Point> = new Vector.<Point>;
			for (var i:int = 0, l:int = points.length; i < l; i++) {
				if (clonedPoints.length >= i) clonedPoints[i] = points[i].clone();
			}
			var newZone:PolylineZone = new PolylineZone;
			newZone.setPoints(clonedPoints);
			return newZone;
		}
		
		public function copy():PolylineZone {
			var newZone:PolylineZone = new PolylineZone;
			newZone.setPoints(points.concat());
			return newZone;
		}
		
		public function inflate(distance:Number):void {
			var deflate:Boolean = distance < 0;
			distance = Math.abs(distance);
			if (!testPoint) testPoint = new Point;
			for (var i:int = 0, l:int = points.length; i < l; i++) {
				var pt:Point = points[i],
					pi:int = i - 1,
					ni:int = i + 1,
					a:Point = points[pi < 0 ? l - 1 : pi],
					b:Point = points[ni == l ? 0 : ni],
					d1:Number = PlanimetryUtil.getDirectionBetweenPoints(pt, a),
					d2:Number = PlanimetryUtil.getDirectionBetweenPoints(pt, b);
					
				var d:Number = Math.min(d1, d2) + Math.abs(d1 - d2) / 2;
				testPoint.copyFrom(pt);
				testPoint.x += Math.sin(d) * distance;
				testPoint.y -= Math.cos(d) * distance;
				
				var valid:Boolean = contains(testPoint);
				if (deflate) valid = !valid;
				
				if (valid) {
					d += MathUtil.PI;
					pt.x += Math.sin(d) * distance;
					pt.y -= Math.cos(d) * distance;
				} else
					pt.copyFrom(testPoint);
			}
			updateBoundingRectangle();
		}
		
		public function addDeltaXY(dx:Number, dy:Number):void {
			for (var i:int = 0, l:int = points.length; i < l; i++) {
				var pt:Point = points[i];
				pt.x += dx;
				pt.y += dy;
			}
			updateBoundingRectangle();
		}
		
		public function subtractPoint(point:Point):void {
			addDeltaXY(-point.x, -point.y);
		}
		
		public function setPosition(point:Point):void {
			addDeltaXY(point.x - rect.width / 2 - rect.x, point.y - rect.height / 2 - rect.y);
		}
		
		override public function destroy():void {
			clear();
			points = null;
			rect = null;
			randomPt = null;
			if (testTr) {
				testTr.destroy();
				testTr = null;
			}
			super.destroy();
		}
		
	}

}