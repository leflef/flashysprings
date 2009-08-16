package {
	import com.rk4.Derivative;
	import com.rk4.State;
	import com.rk4.Vector2D;
	import com.spring.DerivativeHolder;
	import com.spring.IAnchor;
	import com.spring.MouseAnchor;
	import com.spring.SpringNode;

	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	[SWF(width=1024, height = 768)]
	public class RK4Test extends Sprite {

		public static const STEP_DT:Number = 1 / 60; // run physics simulation at 60 fps
		public var accumulator:Number = 0;
		public var prevTime:Number = 0;
		public var time:Number = 0;
		public var object:Sprite;
		public var prevState:State;
		public var currentState:State;
		public var debugText:TextField;

		public function RK4Test() {
			stage.frameRate = 120;

			debugText = new TextField();
			addChild(debugText);

			currentState = new State();

			createCloth(currentState, 5, 5);
			//createString(currentState, 5, 10, 10);

			prevState = currentState.clone();

			prevTime = getTimer();
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		protected function onKeyDown(event:KeyboardEvent):void {

			var randomNode:SpringNode = currentState.getAt((Math.random() * (currentState.springs.length - 1)) << 0);
			switch (event.keyCode) {
				case Keyboard.UP:
					randomNode.momentum = randomNode.momentum.add(new Vector2D(0, -200));
					break;
				case Keyboard.LEFT:
					randomNode.momentum = randomNode.momentum.add(new Vector2D(-200, 0));
					break;
				case Keyboard.RIGHT:
					randomNode.momentum = randomNode.momentum.add(new Vector2D(200, 0));
					break;
				default:
					break;
			}
		}

		protected function onMouseDown(event:MouseEvent):void {

		}

		/**
		 * Creates a grid for a cloth
		 *
		 * 1 -- 2 -- 3
		 * 4 -- 5 -- 6
		 * 7 -- 8 -- 9
		 * and so on...
		 */
		protected function createCloth(state:State, rows:Number = 3, cols:Number = 5, gridWidth:Number = 20, gridHeight:Number = 20, natDist:Number = 20):void {
			var offset:Vector2D = new Vector2D(100, 100);
			var i:uint;
			var j:uint;
			var currentIdx:uint;

			// Create the springs in a row
			for (i = 0; i < rows; i++) {
				for (j = 0; j < cols; j++) {
					state.springs.push(new SpringNode(new Vector2D(offset.x + (j * gridWidth), offset.y + (i * gridHeight)), 1.0));
				}
			}

			// Attach left links
			// 1 --> 2 --> 3
			//
			for (i = 0; i < rows; i++) {
				for (j = 0; j < cols - 1; j++) {

					currentIdx = (i * cols) + j;
					var rightNeighborIdx:uint = (i * cols) + (j + 1);

					state.getAt(currentIdx).neighbors.push(state.getAt(rightNeighborIdx));
					state.getAt(currentIdx).naturalDistance.push(natDist);
				}
			}

			// Attach right links
			// 1 <-- 2 <-- 3
			for (i = 0; i < rows; i++) {
				for (j = cols - 1; j > 0; j--) {

					currentIdx = (i * cols) + j;
					var leftNeighborIdx:uint = (i * cols) + (j - 1);

					state.getAt(currentIdx).neighbors.push(state.getAt(leftNeighborIdx));
					state.getAt(currentIdx).naturalDistance.push(natDist);
				}
			}

			// Attach down links
			// 1 -- 2 -- 3
			// |    |    |
			// V    V    V
			// 1 -- 2 -- 3
			for (j = 0; j < cols; j++) {
				for (i = 0; i < rows - 1; i++) {

					currentIdx = (i * cols) + j;
					var downNeighborIdx:uint = ((i + 1) * cols) + j;

					state.getAt(currentIdx).neighbors.push(state.getAt(downNeighborIdx));
					state.getAt(currentIdx).naturalDistance.push(natDist);
				}
			}

			// Attach up links
			// 1 -- 2 -- 3
			// ^    ^    ^
			// |    |    |
			// 1 -- 2 -- 3
			for (j = 0; j < cols; j++) {
				for (i = rows - 1; i > 0; i--) {

					currentIdx = (i * cols) + j;
					var upNeighborIdx:uint = ((i - 1) * cols) + j;

					state.getAt(currentIdx).neighbors.push(state.getAt(upNeighborIdx));
					state.getAt(currentIdx).naturalDistance.push(natDist);
				}
			}

			var anchor1:IAnchor = new MouseAnchor(state.getAt(0), this);
			//state.anchors.push(anchor1);

			var anchor2:IAnchor = new MouseAnchor(state.getAt(cols - 1), this, new Vector2D((cols - 1) * gridWidth));
			//state.anchors.push(anchor2);
		}

		/**
		 * Creates a row of nodes simulating a string
		 */
		protected function createString(state:State, totalNodes:Number = 5, natDist:Number = 10, distance:Number = 10):void {
			var offset:Vector2D = new Vector2D(stage.stageWidth / 2, stage.stageHeight / 4);
			var i:uint;

			// Create the springs in a row
			for (i = 0; i < totalNodes; i++) {
				var springNode:SpringNode = new SpringNode(new Vector2D(offset.x + (i * distance), offset.y), 1);
				state.springs.push(springNode);
			}

			// Connect left nodes
			// 1 --> 2
			for (i = 0; i < totalNodes - 1; i++) {
				state.getAt(i).neighbors.push(state.getAt(i + 1));
				state.getAt(i).naturalDistance.push(natDist);
			}

			// Connect right nodes
			// 2 <-- 1
			for (i = totalNodes - 1; i > 0; i--) {
				state.getAt(i).neighbors.push(state.getAt(i - 1));
				state.getAt(i).naturalDistance.push(natDist);
			}

			//var anchor:IAnchor = new StaticAnchor(state.getAt(0));
			//var anchor:IAnchor = new MouseAnchor(state.getAt(0), this);
			//state.anchors.push(anchor);

			return;
		}

		/**
		 * Render loop
		 */
		public function onEnterFrame(... ignored):void {
			// Reset debug text
			debugText.text = "";

			var deltaTime:Number = getTimer() - prevTime;
			deltaTime *= .001;
			prevTime = getTimer();

			accumulator += deltaTime;

			while (accumulator >= STEP_DT) {
				prevState = currentState.clone();
				integrate(currentState, time, STEP_DT);
				//euler(currentState, time, STEP_DT);
				time += STEP_DT;
				accumulator -= STEP_DT;
			}

			// Interpolate states if fps is higher than physics time
			var alpha:Number = accumulator / STEP_DT;
			var interState:State = new State();
			interState.interpolate(alpha, currentState, prevState);

			render(interState);
		}

		public function render(state:State):void {
			graphics.clear();

			var springNode:SpringNode;
			var i:int = 0;

			for (i = 0; i < state.springs.length; i++) {
				springNode = state.getAt(i);
				graphics.beginFill(0xFFFFFF);
				graphics.drawCircle(springNode.pos.x, springNode.pos.y, 3);
				graphics.endFill();
			}

			graphics.lineStyle(1, 0x000000);
			for (i = 0; i < state.springs.length; i++) {
				springNode = state.getAt(i);
				for each (var neighbor:SpringNode in springNode.neighbors) {
					graphics.moveTo(springNode.pos.x, springNode.pos.y);
					graphics.lineTo(neighbor.pos.x, neighbor.pos.y);
				}
			}
		}

		public function integrate(state:State, t:Number, dt:Number):void {
			var a:DerivativeHolder = evaluate(state, t, 0.0, new DerivativeHolder(state.springs.length));
			var b:DerivativeHolder = evaluate(state, t, dt * 0.5, a);
			var c:DerivativeHolder = evaluate(state, t, dt * 0.5, b);
			var d:DerivativeHolder = evaluate(state, t, dt, c);

			for (var i:Number = 0; i < state.springs.length; i++) {
				var aD:Derivative = a.getAt(i);
				var bD:Derivative = b.getAt(i)
				var cD:Derivative = c.getAt(i)
				var dD:Derivative = d.getAt(i)

				// dxdt = get velocity using rk4
				var dxdt:Vector2D = bD.vel.add(cD.vel).multiplyScalar(2.0).add(aD.vel).add(dD.vel).multiplyScalar(1.0 / 6.0);
				// dpdt = get force using rk4
				var dpdt:Vector2D = bD.force.add(cD.force).multiplyScalar(2.0).add(aD.force).add(dD.force).multiplyScalar(1.0 / 6.0);

				// p = mv
				// v = p / m
				var currentSpring:SpringNode = state.getAt(i);
				var prevPos:Vector2D = currentSpring.pos.clone();
				// x = x + v * dt
				currentSpring.pos = currentSpring.pos.add(dxdt.multiplyScalar(dt));
				// p = p + f * dt
				currentSpring.momentum = currentSpring.momentum.add(dpdt.multiplyScalar(dt));
				// recompute velocity
				currentSpring.vel = currentSpring.momentum.multiplyScalar(currentSpring.inverseMass);

				if (currentSpring.pos.y > 300) {
					var penetrationVector:Vector2D = prevPos.subtract(currentSpring.pos);
					currentSpring.pos.y = 300;
					currentSpring.vel.y = 0;
					currentSpring.momentum = currentSpring.vel.multiplyScalar(currentSpring.mass);
				}
			}

			for each (var anchor:IAnchor in state.anchors) {
				anchor.holdAnchor();
			}
		}


		public function evaluate(initial:State, t:Number, dt:Number, inputDerivatives:DerivativeHolder):DerivativeHolder {
			var outputDerivatives:DerivativeHolder = new DerivativeHolder(initial.springs.length);

			for (var i:Number = 0; i < initial.springs.length; i++) {
				var spring:SpringNode = initial.getAt(i);
				var derivative:Derivative = inputDerivatives.getAt(i);

				// Here we do a simple Euler Integration
				var newSpring:SpringNode = new SpringNode();
				newSpring.pos = spring.pos.add(derivative.vel.multiplyScalar(dt));
				newSpring.momentum = spring.momentum.add(derivative.force.multiplyScalar(dt));

				newSpring.vel = newSpring.momentum.multiplyScalar(newSpring.inverseMass);
				newSpring.neighbors = spring.neighbors.concat();
				newSpring.naturalDistance = spring.naturalDistance.concat();

				var derivativeOut:Derivative = new Derivative();
				derivativeOut.force = calcSingleForce(newSpring, t, dt);
				derivativeOut.vel = newSpring.momentum.multiplyScalar(newSpring.inverseMass);

				outputDerivatives.setAt(i, derivativeOut);
			}

			return outputDerivatives;
		}


		public function calcSingleForce(spring:SpringNode, t:Number, dt:Number):Vector2D {
			var result:Vector2D = new Vector2D();
			var source:Vector2D = new Vector2D();
			var dest:Vector2D = new Vector2D();
			var force:Vector2D = new Vector2D;
			source = spring.pos.clone();

			for (var i:Number = 0; i < spring.neighbors.length; i++) {
				var neighbor:SpringNode = spring.neighbors[i];
				dest = neighbor.pos.clone();

				spring.distances[i] = spring.pos.distance(neighbor.pos);

				var relVel:Vector2D = spring.vel.subtract(neighbor.vel);
				force = SpringNode.calculateForce(force, dest, source, -200.0, spring.naturalDistance[i], relVel);
				result = result.add(force);
			}

			// Apply gravity
			result = result.add(new Vector2D(0, spring.mass * 200));
			return result;
		}

		public function euler(state:State, t:Number, dt:Number):void {
			for (var i:Number = 0; i < state.springs.length; i++) {
				var spring:SpringNode = state.getAt(i);

				// Here we do a simple Euler Integratioin
				spring.pos = spring.pos.add(spring.vel.multiplyScalar(dt));

				// vel = vel + acceleration
				spring.vel = spring.vel.add(calcSingleForce(spring, t, dt).multiplyScalar(spring.inverseMass).multiplyScalar(dt));

				// momentum(p) = mass * velocity
				// also dp/dt = f
				spring.momentum = spring.vel.multiplyScalar(spring.mass);

				// vel = momentum / mass
				spring.vel = spring.momentum.multiplyScalar(spring.inverseMass);
			}
		}
	}
}
