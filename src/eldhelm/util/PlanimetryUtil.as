package eldhelm.util {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Andrey Glavchev
	 */
	public class PlanimetryUtil {
		
		public static const HALF_PI:Number = Math.PI / 2;
		
		public static function getDirectionBetweenPoints(pt1:Point, pt2:Point, r:Number = NaN):Number {
			return getDirection(pt2.x - pt1.x, pt2.y - pt1.y);
		}
		
		public static function getDirection(dx:Number, dy:Number, r:Number = NaN):Number {
			var targetRotation:Number = Math.atan2(dy, dx) + HALF_PI;
			if (!isNaN(r)) targetRotation = clampDirectionDelta(targetRotation, r);
			return targetRotation;
		}
		
		[Inline]
		public static function clampDirectionDelta(targetRotation:Number, r:Number):Number {
			if (Math.abs(targetRotation - r) >= Math.PI) {
				if (targetRotation > r) {
					targetRotation -= 2 * Math.PI;
				} else {
					targetRotation += 2 * Math.PI;
				}
			}
			return targetRotation;
		}
		
		[Inline]
		public static function getDistance(dx:Number, dy:Number):Number {
			return Math.sqrt(Math.pow(dy, 2) + Math.pow(dx, 2));
		}
		
		[Inline]
		public static function getDistanceBetweenPoints(pt1:Point, pt2:Point):Number {
			return getDistance(pt1.x - pt2.x, pt1.y - pt2.y);
		}
		
		[Inline]
		public static function polar(c:Point, angle:Number, radius:Number, pt:Point):Point {
			pt.x = c.x + Math.sin(angle) * radius;
			pt.y = c.y - Math.cos(angle) * radius;
			return pt;
		}
		
		public static function centerToTopLeft(c:Object, pt:Point = null):Point {
			if (!pt) pt = new Point;
			pt.x = c.x - c.width / 2;
			pt.y = c.y - c.height / 2;
			return pt;
		}
		
	}

}