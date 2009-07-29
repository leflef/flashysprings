package com.spring {
	import com.math.Mass;

	public class Spring {
		public var massA:Mass;
		public var massB:Mass;

		public var k:Number;
		public var l:Number;
		public var b:Number;

		public function Spring(massA:Mass, massB:Mass, k:Number, l:Number, b:Number) {
			this.massA = massA;
			this.massB = massB;
			this.k = k;
			this.l = l;
			this.b = b;
		}

	}
}