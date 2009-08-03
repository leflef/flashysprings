package com.spring {
	import com.rk4.Vector2D;


	public class SpringNode {

		// constant
		public static const MASS:Number = 1.0;
		public static const INVERSE_MASS:Number = 1.0/MASS;

		public var neighbors:Array = [];
		public var naturalDistance:Array = [];

		// primary
		public var pos:Vector2D = new Vector2D();
		public var momentum:Vector2D = new Vector2D();

		// secondary
		public var vel:Vector2D = new Vector2D();

		public function clone():SpringNode {
			var newState:SpringNode = new SpringNode();
			newState.momentum = momentum.clone();
			newState.pos = pos.clone();
			newState.vel = vel.clone();
			return newState;
		}

		public static function calculateForce(force:Vector2D, pa:Vector2D, pb:Vector2D, k:Number, natDistance:Number, relVel:Vector2D):Vector2D {
			var dx:Number = pb.x - pa.x;
			var dy:Number = pb.y - pa.y;

			var distance:Number = Math.sqrt((dx * dx) + (dy * dy));

			if (distance < 0.000000005) {
				force.zero();
				return force;
			}
			
			var forceDir:Vector2D = new Vector2D(dx, dy);
			forceDir.normalize(distance);
			
			var damper:Vector2D = relVel.multiplyScalar(1);
			
			var kComp:Vector2D = forceDir.multiplyScalar(distance).multiplyScalar(-k);
			var newForce:Vector2D = kComp;


			return newForce;
		}
	}
}