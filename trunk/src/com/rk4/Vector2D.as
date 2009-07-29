package com.rk4 {

	/**
	 * @author bsu
	 */
	public class Vector2D {
		public var x:Number;
		public var y:Number;

		public function Vector2D(x:Number = 0, y:Number = 0):void {
			this.x = x;
			this.y = y;
		}

		public function multiplyScalar(value:Number):Vector2D {
			var newVec:Vector2D = new Vector2D();
			
			newVec.x = value * x;
			newVec.y = value * y;
			
			return newVec;
		}

		public function multiply(vector:Vector2D):Vector2D {
			var newVec:Vector2D = new Vector2D();
			
			newVec.x = vector.x * x;
			newVec.y = vector.y * y;
			
			return newVec;
		}

		public function add(vector:Vector2D):Vector2D {
			var newVec:Vector2D = new Vector2D();
			
			newVec.x = x + vector.x;
			newVec.y = y + vector.y;
			
			return newVec;
		}
	}
}
