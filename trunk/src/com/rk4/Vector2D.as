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

		public function clone():Vector2D {
			return new Vector2D(x, y);
		}

		public function normalize(distance:Number):void {
			x /= distance;
			y /= distance;
		}


		public function zero():void {
			x = 0;
			y = 0;
		}

		public function distance(vector:Vector2D):Number {
			var dx:Number = x - vector.x;
			var dy:Number = y - vector.y;

			return Math.sqrt((dx * dx) + (dy * dy));
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


		public function subtract(vector:Vector2D):Vector2D {
			var newVec:Vector2D = new Vector2D();

			newVec.x = x - vector.x;
			newVec.y = y - vector.y;

			return newVec;
		}

		public function dot(vector:Vector2D):Number {
			return x * vector.x + y * vector.y;
		}

		public function toString():String {
			return "(" + x + "," + y + ")";
		}
	}
}
