package {
	import com.rk4.Derivative;
	import com.rk4.State;
	import com.rk4.Vector2D;
	import com.spring.DerivativeHolder;
	import com.spring.SpringAnchor;
	import com.spring.SpringNode;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	[SWF(width=1024, height = 768)]
	public class RK4Test extends Sprite {


		public static const STEP_DT:Number = 1 / 120; // run physics simulation at 60 fps
		public var accumulator:Number = 0;
		public var prevTime:Number = 0;
		public var time:Number = 0;
		public var object:Sprite;
		public var prevState:State;
		public var currentState:State;

		// Spring Stuff
		public static const TOTAL_NODES:Number = 2;

		public function RK4Test() {
			stage.frameRate = 60;


			currentState = new State();
			prevState = new State();

			createString();

			x = 100;
			y = 100;

			prevTime = getTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		protected function createString():void {
			var distance:Number = 20.0;

			// Create the springs in a row
			for (var i:int = 0; i < TOTAL_NODES; i++) {
				var springNode:SpringNode = new SpringNode();
				springNode.pos = new Vector2D((stage.stageWidth / 2) + i * (distance));
				currentState.springs.push(springNode);
			}

			// Connect first spring
			currentState.springs[0].neighbors.push(currentState.springs[1]);
			currentState.springs[0].naturalDistance.push(distance);

			// Connect last spring
			currentState.springs[TOTAL_NODES - 1].neighbors.push(currentState.springs[TOTAL_NODES - 2]);
			currentState.springs[TOTAL_NODES - 1].naturalDistance.push(distance);

			// Connect the nodes
			for (var j:int = 1; j < TOTAL_NODES - 1; j++) {
				currentState.springs[j].neighbors.push(currentState.springs[j - 1]);
				currentState.springs[j].naturalDistance.push(distance);

				currentState.springs[j].neighbors.push(currentState.springs[j + 1]);
				currentState.springs[j].naturalDistance.push(distance);
			}

			var anchor:SpringAnchor = new SpringAnchor();
			anchor.pos = currentState.springs[0].pos.clone();

			currentState.anchors.push(anchor);

			return;
		}

		public function randomValue(value:Number):Number {
			return (Math.random() * value + value) - (Math.random() * value + value);
		}


		public function onEnterFrame(... ignored):void {
			var deltaTime:Number = getTimer() - prevTime;
			deltaTime *= .001;
			prevTime = getTimer();

			accumulator += deltaTime;

			while (accumulator >= STEP_DT) {
				//prevState = currentState.clone();
				integrate(currentState, time, STEP_DT);
				time += STEP_DT;
				accumulator -= STEP_DT;
			}

			// Interpolate states if fps is higher than physics timeF
			//var alpha:Number = accumulator / STEP_DT;
			//var interState:State = new State();
			//interState.interpolate(alpha, currentState, prevState);

			//render(interState);
			render(currentState);
		}

		public function render(state:State):void {
			graphics.clear();
			for (var j:int = 1; j < state.springs.length; j++) {
				var springNode:SpringNode = state.springs[j] as SpringNode;
				graphics.moveTo(springNode.pos.x, springNode.pos.y);

				graphics.lineStyle(0, 0x000000);
				graphics.beginFill(0xFFFFFF);
				graphics.drawCircle(springNode.pos.x, springNode.pos.y, 3);
				graphics.endFill();

				graphics.lineStyle(1, 0x000000);
				graphics.moveTo(springNode.pos.x, springNode.pos.y);
				graphics.lineTo(springNode.neighbors[0].pos.x, springNode.neighbors[0].pos.y);
			}
		}

		public function integrate(state:State, t:Number, dt:Number):void {
			var a:DerivativeHolder = evaluate(state, t, 0.0, new DerivativeHolder());
			var b:DerivativeHolder = evaluate(state, t, dt * 0.5, a);
			var c:DerivativeHolder = evaluate(state, t, dt * 0.5, b);
			var d:DerivativeHolder = evaluate(state, t, dt, c);

			for (var i:Number = 0; i < TOTAL_NODES; i++) {
				var aD:Derivative = a.getAt(i);
				var bD:Derivative = b.getAt(i)
				var cD:Derivative = c.getAt(i)
				var dD:Derivative = d.getAt(i)

				var dxdt:Vector2D = (bD.vel.add(cD.vel)).multiplyScalar(2.0).add(aD.vel).add(dD.vel).multiplyScalar(1.0 / 6.0);
				var dpdt:Vector2D = (bD.force.add(cD.force)).multiplyScalar(2.0).add(aD.force).add(dD.force).multiplyScalar(1.0 / 6.0);

				var currentSpring:SpringNode = state.springs[i];
				currentSpring.pos = dxdt.multiplyScalar(dt).add(currentSpring.pos);
				currentSpring.momentum = dpdt.multiplyScalar(dt).add(currentSpring.momentum);

				currentSpring.vel = currentSpring.momentum.multiplyScalar(SpringNode.INVERSE_MASS);
			}
		}


		public function evaluate(initial:State, t:Number, dt:Number, inputDerivatives:DerivativeHolder):DerivativeHolder {
			var outputDerivatives:DerivativeHolder = new DerivativeHolder();

			for (var i:Number = 0; i < TOTAL_NODES; i++) {
				var curSpring:SpringNode = SpringNode(initial.springs[i]);
				var curDeriv:Derivative = inputDerivatives.getAt(i);

				var newSpring:SpringNode = new SpringNode();
				newSpring.pos = curSpring.pos.add(curDeriv.vel.multiplyScalar(dt));
				newSpring.momentum = curSpring.momentum.add(curDeriv.force.multiplyScalar(dt));
				newSpring.neighbors = curSpring.neighbors.concat();
				newSpring.naturalDistance = curSpring.naturalDistance.concat();

				var derivativeOut:Derivative = new Derivative();
				derivativeOut.vel = newSpring.momentum.multiplyScalar(SpringNode.INVERSE_MASS);
				derivativeOut.force = calcSingleForce(newSpring, t, dt);
				
				outputDerivatives.setAt(i, derivativeOut);

			}

			initial.springs[0].pos = SpringAnchor(initial.anchors[0]).pos;
			initial.springs[0].momentum.zero();
			initial.springs[0].vel.zero();

			//state.pos = initial.pos.add(derivative.vel.multiplyScalar(dt));
			//state.vel = initial.vel.add(derivative.force.multiplyScalar(dt));

			//derivativeOut.vel = state.vel;
			//derivativeOut.force = acceleration(state, t, dt);
			return outputDerivatives;
		}


		public function calcSingleForce(spring:SpringNode, t:Number, dt:Number):Vector2D {
			var result:Vector2D = new Vector2D();
			var source:Vector2D = new Vector2D();
			var dest:Vector2D = new Vector2D();
			var force:Vector2D = new Vector2D;
			var naturalDistance:Number;
			result.zero();
			source = spring.pos.clone();

			for (var i:Number = 0; i < spring.neighbors.length; i++) {
				var neighbor:SpringNode = spring.neighbors[i];

				dest = neighbor.pos.clone();
				naturalDistance = spring.naturalDistance[i];

				var relVel:Vector2D = neighbor.vel.subtract(spring.vel);
				force = SpringNode.calculateForce(force, source, dest, 10.0, naturalDistance,relVel);

				result = result.add(force);
			}

			//result = result.add(new Vector2D(0, 100));
			return result;
		}

	}
}
