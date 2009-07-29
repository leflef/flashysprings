package com.rk4 {

	public class State {
		public const mass:Number = 1.0;
		public var pos:Vector2D = new Vector2D();
		public var vel:Vector2D = new Vector2D();

		public function clone():State {
			var newState:State = new State();
			newState.pos = pos;
			newState.vel = vel;
			return newState;
		}

		public function interpolate(alpha:Number, curState:State, prevState:State):void {
			pos = curState.pos.multiplyScalar(alpha).add(prevState.pos.multiplyScalar((1.0 - alpha)));
			vel = curState.vel.multiplyScalar(alpha).add(prevState.vel.multiplyScalar((1.0 - alpha)));
		}
	}
}