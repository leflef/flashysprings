package com.rk4 {
	import com.spring.SpringNode;


	public class State {


		// spring stuff
		public var springs:Array = [];
		public var anchors:Array = [];


		public function getAt(index:Number):SpringNode {
			return springs[index] as SpringNode;
		}

		public function setAt(index:Number, value:SpringNode):void {
			springs[index] = value;
		}

		public function interpolate(alpha:Number, curState:State, prevState:State):void {
			//pos = curState.pos.multiplyScalar(alpha).add(prevState.pos.multiplyScalar((1.0 - alpha)));
			//vel = curState.vel.multiplyScalar(alpha).add(prevState.vel.multiplyScalar((1.0 - alpha)));
		}
	}
}