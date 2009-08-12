package com.rk4 {
	import com.spring.SpringNode;


	public class State {


		// spring stuff
		public var springs:Array = [];
		public var anchors:Array = [];

		public function clone():State {
			var clone:State = new State();
			for (var j:int = 0; j < springs.length; j++) {
				var newSpring:SpringNode = getAt(j).clone();
				clone.springs.push(newSpring);
			}
			return clone;
		}

		public function getAt(index:Number):SpringNode {
			return springs[index] as SpringNode;
		}

		public function setAt(index:Number, value:SpringNode):void {
			springs[index] = value;
		}

		//currentState*alpha + previousState*(1.0f-alpha)
		public function interpolate(alpha:Number, curState:State, prevState:State):void {
			for (var j:int = 0; j < curState.springs.length; j++) {
				var curSpringState:SpringNode = curState.getAt(j);
				var prevSpringState:SpringNode = prevState.getAt(j);

				var interpSpring:SpringNode = new SpringNode();
				interpSpring.pos = curSpringState.pos.multiplyScalar(alpha).add(prevSpringState.pos.multiplyScalar(1.0 - alpha));
				interpSpring.neighbors = curSpringState.neighbors.concat();
				springs.push(interpSpring);
			}
		}
	}
}