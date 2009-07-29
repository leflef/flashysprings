package com.math {
	import com.rk4.Vector2D;

	public class Mass {
		public var m:Number;
		public var pos:Vector2D;
		public var vel:Vector2D;
		public var force:Vector2D;

		public function Mass() {


			public function Mass(m:Number):void {
				this.m = m;
			}

			public function applyForce(force:Vector2D):void {
				this.force = this.force.add(force);
			}

			public function init():void {
				force.x = 0;
				force.y = 0;
			}
		}

	}
}