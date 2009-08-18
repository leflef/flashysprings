package {
	import com.rk4.Derivative;
	import com.rk4.State;
	import com.rk4.Vector2D;
	import com.spring.DerivativeHolder;
	import com.spring.IAnchor;
	import com.spring.MouseAnchor;
	import com.spring.SpringNode;
	import com.spring.StaticAnchor;

	import flash.display.MovieClip;
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

			//createCloth(currentState, 6, 6);
			createString(currentState, 10, 10, 10);
			//createJello(currentState, 4, 4);

			prevState = currentState.clone();

			prevTime = getTimer();
			prevMouseX = mouseX;
			prevMouseY = mouseY;
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		protected function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.RIGHT:
					for each (var node:SpringNode in currentState.springs) {
						node.momentum = node.momentum.add(new Vector2D(-50, 0));

					}
					break;
				default:
					break;
			}
		}
		protected var _dragNode:SpringNode = null;

		protected function onMouseDown(event:MouseEvent):void {
			var targetSpring:SpringNode = event.target.spring;
			_dragNode = targetSpring;
		}

		protected function onMouseUp(event:MouseEvent):void {
			_dragNode = null;
		}

		protected function createJello(state:State, rows:Number = 2, cols:Number = 2, gridWidth:Number = 20, gridHeight:Number = 20, natDist:Number = 20):void {
			var offset:Vector2D = new Vector2D(stage.stageWidth / 2, 100);
			var i:uint;
			var j:uint;
			var currentIdx:uint;

			// Create the springs in a row
			for (i = 0; i < rows; i++) {
				for (j = 0; j < cols; j++) {
					var node:SpringNode = new SpringNode(new Vector2D(offset.x + (j * gridWidth), offset.y + (i * gridHeight)), 1.0, 200);

					var clickArea:MovieClip = new MovieClip();
					clickArea.graphics.beginFill(0xFFFFFF, 1)
					clickArea.graphics.drawCircle(0, 0, 5);
					clickArea.graphics.endFill();
					clickArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					clickArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					clickArea.spring = node;

					node.data = new Object();
					node.data.graphic = clickArea;

					addChild(clickArea);
					clickArea.x = node.pos.x;
					clickArea.y = node.pos.y;

					state.springs.push(node);
				}
			}

			var totalWidth:Number = (cols - 1) * gridWidth;
			var totalHeight:Number = (rows - 1) * gridHeight;

			var centerMassSpring:SpringNode = new SpringNode(new Vector2D(offset.x + totalWidth / 2, offset.y + totalHeight / 2), 0.6, 1500);
			var massSpringIdx:Number = state.springs.length;
			state.springs.push(centerMassSpring);

			for (i = 0; i < rows - 1; i++) {
				for (j = 0; j < cols - 1; j++) {
					generateStrongMesh(state, (i * cols) + j, massSpringIdx, cols, natDist);
				}
			}

			//var anchor1:IAnchor = new StaticAnchor(centerMassSpring);
			//state.anchors.push(anchor1);
		}

		protected function generateStrongMesh(state:State, startIdx:uint, centerMassIndex:uint, cols:Number, natDist:Number):void {
			var centerMassSpring:SpringNode = state.getAt(centerMassIndex);

			var topLeft:uint = startIdx;
			var topRight:uint = startIdx + 1;
			var bottomLeft:uint = startIdx + cols;
			var bottomRight:uint = startIdx + cols + 1;

			var diagonalLength:Number = state.getAt(topLeft).pos.distance(state.getAt(bottomRight).pos);

			state.getAt(topLeft).neighbors.push(state.getAt(topRight));
			state.getAt(topLeft).naturalDistance.push(natDist);
			state.getAt(topRight).neighbors.push(state.getAt(topLeft));
			state.getAt(topRight).naturalDistance.push(natDist);

			state.getAt(bottomLeft).neighbors.push(state.getAt(bottomRight));
			state.getAt(bottomLeft).naturalDistance.push(natDist);
			state.getAt(bottomRight).neighbors.push(state.getAt(bottomLeft));
			state.getAt(bottomRight).naturalDistance.push(natDist);

			state.getAt(topLeft).neighbors.push(state.getAt(bottomLeft));
			state.getAt(topLeft).naturalDistance.push(natDist);
			state.getAt(bottomLeft).neighbors.push(state.getAt(topLeft));
			state.getAt(bottomLeft).naturalDistance.push(natDist);

			state.getAt(topRight).neighbors.push(state.getAt(bottomRight));
			state.getAt(topRight).naturalDistance.push(natDist);
			state.getAt(bottomRight).neighbors.push(state.getAt(topRight));
			state.getAt(bottomRight).naturalDistance.push(natDist);

			state.getAt(startIdx).neighbors.push(state.getAt(cols + startIdx + 1));
			state.getAt(startIdx).naturalDistance.push(diagonalLength);
			state.getAt(cols + startIdx + 1).neighbors.push(state.getAt(startIdx));
			state.getAt(cols + startIdx + 1).naturalDistance.push(diagonalLength);

			state.getAt(startIdx + 1).neighbors.push(state.getAt(cols + startIdx));
			state.getAt(startIdx + 1).naturalDistance.push(diagonalLength);
			state.getAt(cols + startIdx).neighbors.push(state.getAt(startIdx + 1));
			state.getAt(cols + startIdx).naturalDistance.push(diagonalLength);


			state.getAt(topLeft).neighbors.push(centerMassSpring);
			state.getAt(topLeft).naturalDistance.push(state.getAt(topLeft).pos.distance(centerMassSpring.pos));
			centerMassSpring.neighbors.push(state.getAt(topLeft));
			centerMassSpring.naturalDistance.push(state.getAt(topLeft).pos.distance(centerMassSpring.pos));

			state.getAt(startIdx + 1).neighbors.push(centerMassSpring);
			state.getAt(startIdx + 1).naturalDistance.push(state.getAt(startIdx + 1).pos.distance(centerMassSpring.pos));
			centerMassSpring.neighbors.push(state.getAt(startIdx + 1));
			centerMassSpring.naturalDistance.push(state.getAt(startIdx + 1).pos.distance(centerMassSpring.pos));

			state.getAt(startIdx + cols).neighbors.push(centerMassSpring);
			state.getAt(startIdx + cols).naturalDistance.push(state.getAt(startIdx + cols).pos.distance(centerMassSpring.pos));
			centerMassSpring.neighbors.push(state.getAt(startIdx + cols));
			centerMassSpring.naturalDistance.push(state.getAt(startIdx + cols).pos.distance(centerMassSpring.pos));

			state.getAt(startIdx + cols + 1).neighbors.push(centerMassSpring);
			state.getAt(startIdx + cols + 1).naturalDistance.push(state.getAt(startIdx + cols + 1).pos.distance(centerMassSpring.pos));
			centerMassSpring.neighbors.push(state.getAt(startIdx + cols + 1));
			centerMassSpring.naturalDistance.push(state.getAt(startIdx + cols + 1).pos.distance(centerMassSpring.pos));
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
					var node:SpringNode = new SpringNode(new Vector2D(offset.x + (j * gridWidth), offset.y + (i * gridHeight)), 1.0, 200);

					var clickArea:MovieClip = new MovieClip();
					clickArea.graphics.beginFill(0xFFFFFF, 1)
					clickArea.graphics.drawCircle(0, 0, 2);
					clickArea.graphics.endFill();
					clickArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					clickArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					clickArea.spring = node;

					node.data = new Object();
					node.data.graphic = clickArea;

					addChild(clickArea);
					clickArea.x = node.pos.x;
					clickArea.y = node.pos.y;

					state.springs.push(node);
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
			state.anchors.push(anchor1);

			var anchor2:IAnchor = new MouseAnchor(state.getAt(cols - 1), this, new Vector2D((cols - 1) * gridWidth));
			state.anchors.push(anchor2);
		}

		/**
		 * Creates a row of nodes simulating a string
		 */
		protected function createString(state:State, totalNodes:Number = 5, natDist:Number = 10, distance:Number = 10):void {
			var offset:Vector2D = new Vector2D(stage.stageWidth / 2, stage.stageHeight / 4);
			var i:uint;

			// Create the springs in a row
			for (i = 0; i < totalNodes; i++) {
				var node:SpringNode = new SpringNode(new Vector2D(offset.x + (i * distance), offset.y), 1.0, 200);

				var clickArea:MovieClip = new MovieClip();
				clickArea.graphics.beginFill(0xFFFFFF, 1)
				clickArea.graphics.drawCircle(0, 0, 2);
				clickArea.graphics.endFill();
				clickArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				clickArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				clickArea.spring = node;

				node.data = new Object();
				node.data.graphic = clickArea;

				addChild(clickArea);
				clickArea.x = node.pos.x;
				clickArea.y = node.pos.y;

				state.springs.push(node);
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
			var anchor:IAnchor = new MouseAnchor(state.getAt(0), this);
			state.anchors.push(anchor);

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

			render(currentState);
		}

		public function render(state:State):void {
			graphics.clear();

			var springNode:SpringNode;
			var i:int = 0;

			for (i = 0; i < state.springs.length; i++) {
				springNode = state.getAt(i);
				//graphics.beginFill(0xFFFFFF);
				//graphics.drawCircle(springNode.pos.x, springNode.pos.y, 3);
				//graphics.endFill();
				if (springNode.data != null) {
					springNode.data.graphic.x = springNode.pos.x;
					springNode.data.graphic.y = springNode.pos.y;
				}
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

				if (currentSpring.pos.y > stage.stageHeight / 2) {
					var penetrationVector:Vector2D = prevPos.subtract(currentSpring.pos);
					currentSpring.pos.y = stage.stageHeight / 2;
					currentSpring.vel.y = -currentSpring.vel.y * 0.75;
					currentSpring.momentum = currentSpring.vel.multiplyScalar(currentSpring.mass);
				}

				if (currentSpring.pos.x < 10) {
					var penetrationVector:Vector2D = prevPos.subtract(currentSpring.pos);
					currentSpring.pos.x = 10;
					currentSpring.vel.x = currentSpring.vel.x;
					currentSpring.momentum = currentSpring.vel.multiplyScalar(currentSpring.mass);
				}
			}

			for each (var anchor:IAnchor in state.anchors) {
				anchor.holdAnchor();
			}

			if (_dragNode != null) {
				var mouseVec:Vector2D = new Vector2D(mouseX - prevMouseX, mouseY - prevMouseY);

				_dragNode.vel = _dragNode.vel.add(mouseVec);
				_dragNode.pos.x = stage.mouseX;
				_dragNode.pos.y = stage.mouseY;
			}

			prevMouseX = mouseX;
			prevMouseY = mouseY;
		}

		public var prevMouseX:Number = 0;
		public var prevMouseY:Number = 0;


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
				newSpring.kVal = spring.kVal;

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
				force = SpringNode.calculateForce(force, dest, source, -spring.kVal, spring.naturalDistance[i], relVel);
				result = result.add(force);
			}

			// Apply gravity
			result = result.add(new Vector2D(0, spring.mass * 400));
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
