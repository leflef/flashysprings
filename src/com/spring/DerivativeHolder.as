package com.spring {
	import com.rk4.Derivative;


	public class DerivativeHolder {

		public var _derivatives:Array;

		public function DerivativeHolder() {
			_derivatives = [];
			for (var i:Number = 0; i < RK4Test.TOTAL_NODES; i++) {
				add(new Derivative());
			}
		}

		public function getAt(i:Number):Derivative {
			return _derivatives[i] as Derivative;
		}

		public function add(d:Derivative):void {
			_derivatives.push(d);
		}
		
		public function setAt(i:Number, d:Derivative):void {
			_derivatives[i] = d;
		}
	}
}