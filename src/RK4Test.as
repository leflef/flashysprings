package {
	import com.rk4.Derivative;
	import com.rk4.State;
	import com.rk4.Vector2D;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;

	public class RK4Test extends Sprite {

		public static const STEP_DT:Number = 1 / 120; // run physics simulation at 60 fps
		public var accumulator:Number = 0;
		public var prevTime:Number = 0;
		public var time:Number = 0;
		public var object:Sprite;
		public var prevState:State;
		public var curState:State;

		public function RK4Test() {
			stage.frameRate = 60;

			object = new Sprite();
			object.graphics.beginFill(0x000000);
			object.graphics.drawCircle(0, 0, 10);
			object.graphics.endFill();
			addChild(object);

			curState = new State();
			curState.pos = new Vector2D(100, 100);
			curState.vel = new Vector2D(300, 300);

			prevState = new State();
			prevState.pos = new Vector2D(100, 100);
			prevState.vel = new Vector2D(300, 300);

			prevTime = getTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.CLICK, onMouseClick);

			x = stage.stageWidth / 2;
			y = stage.stageHeight / 2;
		}

		public function randomValue(value:Number):Number {
			return (Math.random() * value + value) - (Math.random() * value + value);
		}

		public function onMouseClick(... ignored):void {
			curState.vel = curState.vel.add(new Vector2D(randomValue(1000), randomValue(1000)));
		}

		public function onEnterFrame(... ignored):void {
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

			// Interpolate states if fps is higher than physics timeF
			var alpha:Number = accumulator / STEP_DT;
			var interState:State = new State();
			interState.interpolate(alpha, curState, prevState);

			render(interState);
		}

		public function render(state:State):void {
			object.x = state.pos.x;
			object.y = state.pos.y;

			graphics.clear();
			graphics.lineStyle(2, 0x000000);
			graphics.moveTo(0, 0);
			graphics.lineTo(object.x, object.y);
		}

		public function integrate(state:State, t:Number, dt:Number):void {
			var a:Derivative = evaluate(state, t, 0.0, new Derivative());
			var b:Derivative = evaluate(state, t, dt * 0.5, a);
			var c:Derivative = evaluate(state, t, dt * 0.5, b);
			var d:Derivative = evaluate(state, t, dt, c);

			var dxdt:Vector2D = (b.dPos.add(c.dPos)).multiplyScalar(2.0).add(a.dPos).add(d.dPos).multiplyScalar(1.0 / 6.0);
			var dvdt:Vector2D = (b.dVel.add(c.dVel)).multiplyScalar(2.0).add(a.dVel).add(d.dVel).multiplyScalar(1.0 / 6.0);

			state.pos = dxdt.multiplyScalar(dt).add(state.pos);
			state.vel = dvdt.multiplyScalar(dt).add(state.vel);
		}


		public function evaluate(initial:State, t:Number, dt:Number, derivative:Derivative):Derivative {
			var state:State = new State();
			state.pos = initial.pos.add(derivative.dPos.multiplyScalar(dt));
			state.vel = initial.vel.add(derivative.dVel.multiplyScalar(dt));

			var derivativeOut:Derivative = new Derivative();
			derivativeOut.dPos = state.vel;
			derivativeOut.dVel = acceleration(state, t, dt);
			return derivativeOut;
		}

		public function acceleration(state:State, t:Number, dt:Number):Vector2D {
			const k:Number = 10;
			const b:Number = 1;
			return state.pos.multiplyScalar(-k).add(state.vel.multiplyScalar(-b));
		}
	}
}
