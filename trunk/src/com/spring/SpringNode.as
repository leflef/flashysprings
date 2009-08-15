package com.spring {
	import com.rk4.Vector2D;


	public class SpringNode {

		public var neighbors:Array = [];
		public var naturalDistance:Array = [];
		public var distances:Array = []

		// primary
		public var pos:Vector2D = new Vector2D();
		public var momentum:Vector2D = new Vector2D();

		// secondary
		public var vel:Vector2D = new Vector2D();

		// constants
		protected var _mass:Number = 1.0;
		protected var _inverseMass:Number = 1.0 / _mass;


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

			// Which is correct?
			//var damper:Vector2D = forceDir.multiplyScalar(relVel.dot(forceDir) * (20));
			var damper:Vector2D = relVel.multiplyScalar(3);

			var kComp:Vector2D = forceDir.multiplyScalar(distance - natDistance).multiplyScalar(k);
			var newForce:Vector2D = kComp.subtract(damper);

			return newForce;
		}

		public function SpringNode(pos:Vector2D = null, mass = 1.0):void {
			this.pos = (pos != null) ? pos : Vector2D.zeroVector;
			this.mass = mass;
		}

		public function get mass():Number {
			return _mass;
		}

		public function set mass(value:Number):void {
			_mass = value;
			_inverseMass = 1.0 / _mass;
		}

		public function get inverseMass():Number {
			return _inverseMass;
		}


		public function clone():SpringNode {
			var clone:SpringNode = new SpringNode();
			clone.neighbors = neighbors.concat();
			clone.naturalDistance = naturalDistance.concat();
			clone.momentum = momentum.clone();
			clone.pos = pos.clone();
			clone.vel = vel.clone();
			clone.mass = mass;
			return clone;
		}

		public function toString():String {
			return "pos= " + pos + " vel= " + vel + " momentum= " + momentum;
		}


	}
}