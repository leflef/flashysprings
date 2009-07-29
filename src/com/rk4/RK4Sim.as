package com.rk4 {
	import flash.display.Sprite;


	public class RK4Sim extends Sprite {
		public static const STEP_DT:Number = 1 / 120; // run physics simulation at 60 fps
		public var accumulator:Number = 0;
		public var prevTime:Number = 0;
		public var time:Number = 0;

		public var prevState:State;
		public var curState:State;

		public function RK4Test() {

		}

		protected function init():void {
			prevTime = getTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.CLICK, onMouseClick);
		}

		protected function onEnterFrame(... ignored):void {
			var deltaTime:Number = getTimer() - prevTime;
			deltaTime *= .001;
			prevTime = getTimer();

			accumulator += deltaTime;

			while (accumulator >= STEP_DT) {
				prevState = curState.clone();
				integrate(curState, time, STEP_DT);
				time += STEP_DT;
				accumulator -= STEP_DT;
			}

			render(interpolate(accumulator / STEP_DT));
		}

		protected function interpolate(alpha:Number):State {
			throw new Error("Pure virtual function");
		}

		protected function render(state:State):void {
			throw new Error("Pure virtual function");
		}

		protected function acceleration(state:State, t:Number, dt:Number):Vector2D {
			throw new Error("Pure virtual function");
		}

		protected function integrate(state:State, t:Number, dt:Number):void {
			var a:Derivative = evaluate(state, t, 0.0, new Derivative());
			var b:Derivative = evaluate(state, t, dt * 0.5, a);
			var c:Derivative = evaluate(state, t, dt * 0.5, b);
			var d:Derivative = evaluate(state, t, dt, c);

			var dxdt:Vector2D = (b.dPos.add(c.dPos)).multiplyScalar(2.0).add(a.dPos).add(d.dPos).multiplyScalar(1.0 / 6.0);
			var dvdt:Vector2D = (b.dVel.add(c.dVel)).multiplyScalar(2.0).add(a.dVel).add(d.dVel).multiplyScalar(1.0 / 6.0);

			state.pos = dxdt.multiplyScalar(dt).add(state.pos);
			state.vel = dvdt.multiplyScalar(dt).add(state.vel);
		}

		protected function evaluate(initial:State, t:Number, dt:Number, derivative:Derivative):Derivative {
			var state:State = new State();
			state.pos = initial.pos.add(derivative.dPos.multiplyScalar(dt));
			state.vel = initial.vel.add(derivative.dVel.multiplyScalar(dt));

			var derivativeOut:Derivative = new Derivative();
			derivativeOut.dPos = state.vel;
			derivativeOut.dVel = acceleration(state, t, dt);
			return derivativeOut;
		}



	}
}