package {
	import com.rk4.Derivative;
	import com.rk4.State;
	import com.rk4.Vector2D;
	import com.spring.DerivativeHolder;
	import com.spring.IAnchor;
	import com.spring.MouseAnchor;
	import com.spring.SpringNode;
	import com.spring.StaticAnchor;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getTimer;

	[SWF(width=640, height = 480)]
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

			createCloth();
			//createString();

			prevState = currentState.clone();

			prevTime = getTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * Creates a grid for a cloth
		 *
		 * 1 -- 2 -- 3
		 * 4 -- 5 -- 6
		 * 7 -- 8 -- 9
		 * and so on...
		 */
		protected function createCloth():void {
			var rows:Number = 6;
			var cols:Number = 6;
			var offset:Vector2D = new Vector2D(100, 100);
			var gridWidth:Number = 30;
			var gridHeight:Number = 30;
			var i:uint;
			var j:uint;
			var currentIdx:uint;

			// Create the springs in a row
			for (i = 0; i < rows; i++) {
				for (j = 0; j < cols; j++) {
					currentState.springs.push(new SpringNode(new Vector2D(offset.x + (j * gridWidth), offset.y + (i * gridHeight)), 0.9));
				}
			}

			// Attach left links
			// 1 --> 2 --> 3
			//
			for (i = 0; i < rows; i++) {
				for (j = 0; j < cols - 1; j++) {

					currentIdx = (i * cols) + j;
					var rightNeighborIdx:uint = (i * cols) + (j + 1);

					currentState.getAt(currentIdx).neighbors.push(currentState.getAt(rightNeighborIdx));
					currentState.getAt(currentIdx).naturalDistance.push(gridWidth);
				}
			}

			// Attach right links
			// 1 <-- 2 <-- 3
			for (i = 0; i < rows; i++) {
				for (j = cols - 1; j > 0; j--) {

					currentIdx = (i * cols) + j;
					var leftNeighborIdx:uint = (i * cols) + (j - 1);

					currentState.getAt(currentIdx).neighbors.push(currentState.getAt(leftNeighborIdx));
					currentState.getAt(currentIdx).naturalDistance.push(gridWidth);
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

					currentState.getAt(currentIdx).neighbors.push(currentState.getAt(downNeighborIdx));
					currentState.getAt(currentIdx).naturalDistance.push(gridWidth);
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

					currentState.getAt(currentIdx).neighbors.push(currentState.getAt(upNeighborIdx));
					currentState.getAt(currentIdx).naturalDistance.push(gridWidth);
				}
			}

			var anchor1:IAnchor = new MouseAnchor(currentState.getAt(1), this);
			currentState.anchors.push(anchor1);

			var anchor2:IAnchor = new MouseAnchor(currentState.getAt(cols - 2), this, new Vector2D((cols - 1) * gridWidth));
			currentState.anchors.push(anchor2);

			var anchor3:IAnchor = new MouseAnchor(currentState.getAt(rows * (cols - 1)), this, new Vector2D(-gridWidth, gridWidth));
			//currentState.anchors.push(anchor3);

			var anchor4:IAnchor = new MouseAnchor(currentState.getAt(currentState.springs.length - 1), this, new Vector2D((cols) * gridWidth + gridWidth, gridWidth));
			//currentState.anchors.push(anchor4);
		}


		protected function createString():void {
			var distance:Number = 10.0;
			var totalNodes:Number = 10;
			var startIdx:Number = currentState.springs.length - 1;

			// Create the springs in a row
			for (var i:int = startIdx; i < totalNodes; i++) {
				var springNode:SpringNode = new SpringNode();
				springNode.pos = new Vector2D((stage.stageWidth / 2) + i * (distance + 10), 100);
				currentState.springs.push(springNode);
			}

			// Connect first spring
			currentState.getAt(startIdx).neighbors.push(currentState.springs[startIdx + 1]);
			currentState.getAt(startIdx).naturalDistance.push(distance);
			currentState.getAt(startIdx).distances.push(distance);


			// Connect the nodes
			for (var j:int = startIdx + 1; j < totalNodes - 1; j++) {
				currentState.springs[j].neighbors.push(currentState.springs[j - 1]);
				currentState.springs[j].naturalDistance.push(distance);
				currentState.springs[j].distances.push(distance);

				currentState.springs[j].neighbors.push(currentState.springs[j + 1]);
				currentState.springs[j].naturalDistance.push(distance);
				currentState.springs[j].distances.push(distance);
			}

			// Connect last spring
			currentState.getAt(startIdx + totalNodes - 1).neighbors.push(currentState.getAt(startIdx + totalNodes - 2));
			currentState.getAt(startIdx + totalNodes - 1).naturalDistance.push(distance);
			currentState.getAt(startIdx + totalNodes - 1).distances.push(distance);

			var anchor:StaticAnchor = new StaticAnchor(currentState.getAt(0));
			currentState.anchors.push(anchor);

			return;
		}

		public function randomValue(value:Number):Number {
			return (Math.random() * value + value) - (Math.random() * value + value);
		}


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

			//render(currentState);
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

				var dxdt:Vector2D = (bD.vel.add(cD.vel)).multiplyScalar(2.0).add(aD.vel).add(dD.vel).multiplyScalar(1.0 / 6.0);
				var dpdt:Vector2D = (bD.force.add(cD.force)).multiplyScalar(2.0).add(aD.force).add(dD.force).multiplyScalar(1.0 / 6.0);

				var currentSpring:SpringNode = state.getAt(i);
				currentSpring.pos = currentSpring.pos.add(dxdt.multiplyScalar(dt));
				currentSpring.momentum = currentSpring.momentum.add(dpdt.multiplyScalar(dt));

				// assuming unit mass
				currentSpring.vel = currentSpring.momentum.multiplyScalar(currentSpring.inverseMass);

				if (currentSpring.distances[0] > 10) {
					currentSpring.vel.zero();
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
				// Assuming unit masss
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
				force = SpringNode.calculateForce(force, dest, source, -300.0, spring.naturalDistance[i], relVel);
				result = result.add(force);
			}

			// Apply gravity
			result = result.add(new Vector2D(0, spring.mass * 500));
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

		public function holdAnchor(node:SpringNode, point:Vector2D):void {
			// The anchor point should not move			
			node.pos = point;
			//node.pos = anchor.pos;
			node.momentum.zero();
			node.vel.zero();
		}

	}
}
