package {
	import com.rk4.Derivative;
	import com.rk4.State;
	import com.rk4.Vector2D;
	import com.spring.DerivativeHolder;
	import com.spring.SpringAnchor;
	import com.spring.SpringNode;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getTimer;

	[SWF(width=640, height = 480)]
	public class RK4Test extends Sprite {

		public static const STEP_DT:Number = 1 / 120; // run physics simulation at 60 fps
		public var accumulator:Number = 0;
		public var prevTime:Number = 0;
		public var time:Number = 0;
		public var object:Sprite;
		public var prevState:State;
		public var currentState:State;
		public var debugText:TextField;

		// SPRING 
		public static const TOTAL_NODES:Number = 3;

		public function RK4Test() {
			stage.frameRate = 120;

			debugText = new TextField();
			addChild(debugText);

			currentState = new State();

			createString();
			//createBox();

			prevState = currentState.clone();


			prevTime = getTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		protected function createBox():void {
			var vtx1:SpringNode = new SpringNode();
			vtx1.pos = new Vector2D(100, 100);

			var vtx2:SpringNode = new SpringNode();
			vtx2.pos = new Vector2D(200, 100);

			var vtx3:SpringNode = new SpringNode();
			vtx3.pos = new Vector2D(100, 200);

			var vtx4:SpringNode = new SpringNode();
			vtx4.pos = new Vector2D(200, 200);

			var vtx5:SpringNode = new SpringNode();
			vtx5.pos = new Vector2D(150, 150);

			vtx1.neighbors.push(vtx2);
			vtx1.neighbors.push(vtx4);
			vtx1.neighbors.push(vtx5);
			vtx1.naturalDistance.push(100);
			vtx1.naturalDistance.push(100);
			vtx1.naturalDistance.push(100);

			vtx2.neighbors.push(vtx1);
			vtx2.neighbors.push(vtx3);
			vtx2.neighbors.push(vtx5);
			vtx2.naturalDistance.push(100);
			vtx2.naturalDistance.push(100);
			vtx2.naturalDistance.push(100);

			vtx3.neighbors.push(vtx4);
			vtx3.neighbors.push(vtx2);
			vtx3.neighbors.push(vtx5);
			vtx3.naturalDistance.push(100);
			vtx3.naturalDistance.push(100);
			vtx3.naturalDistance.push(100);

			vtx4.neighbors.push(vtx3);
			vtx4.neighbors.push(vtx1);
			vtx4.neighbors.push(vtx5);
			vtx4.naturalDistance.push(100);
			vtx4.naturalDistance.push(100);
			vtx4.naturalDistance.push(100);

			vtx5.neighbors.push(vtx1);
			vtx5.neighbors.push(vtx2);
			vtx5.neighbors.push(vtx3);
			vtx5.neighbors.push(vtx4);
			vtx5.naturalDistance.push(Math.sqrt(20000));
			vtx5.naturalDistance.push(Math.sqrt(20000));
			vtx5.naturalDistance.push(Math.sqrt(20000));
			vtx5.naturalDistance.push(Math.sqrt(20000));

			currentState.springs.push(vtx1);
			currentState.springs.push(vtx2);
			currentState.springs.push(vtx3);
			currentState.springs.push(vtx4);
			currentState.springs.push(vtx5);

			var anchor:SpringAnchor = new SpringAnchor();
			anchor.pos = currentState.springs[0].pos.clone();
			currentState.anchors.push(anchor);
		}

		protected function createString():void {
			var distance:Number = 10.0;

			// Reset debug text
			debugText.text = "";

			// Create the springs in a row
			for (var i:int = 0; i < TOTAL_NODES; i++) {
				var springNode:SpringNode = new SpringNode();
				springNode.pos = new Vector2D((stage.stageWidth / 2) + i * (distance + 10), 100);
				currentState.springs.push(springNode);
			}

			// Connect first spring
			currentState.springs[0].neighbors.push(currentState.springs[1]);
			currentState.springs[0].naturalDistance.push(distance);
			currentState.springs[0].distances.push(distance);


			// Connect the nodes
			for (var j:int = 1; j < TOTAL_NODES - 1; j++) {
				currentState.springs[j].neighbors.push(currentState.springs[j - 1]);
				currentState.springs[j].naturalDistance.push(distance);
				currentState.springs[j].distances.push(distance);

				currentState.springs[j].neighbors.push(currentState.springs[j + 1]);
				currentState.springs[j].naturalDistance.push(distance);
				currentState.springs[j].distances.push(distance);
			}
			
				// Connect last spring
			currentState.springs[TOTAL_NODES - 1].neighbors.push(currentState.springs[TOTAL_NODES - 2]);
			currentState.springs[TOTAL_NODES - 1].naturalDistance.push(distance);
			currentState.springs[TOTAL_NODES - 1].distances.push(distance);

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
				graphics.moveTo(springNode.pos.x, springNode.pos.y);
				for each (var neighbor:SpringNode in springNode.neighbors) {
					graphics.lineTo(neighbor.pos.x, neighbor.pos.y);
				}
			}

		}

		public function integrate(state:State, t:Number, dt:Number):void {
			var a:DerivativeHolder = evaluate(state, t, 0.0, new DerivativeHolder());
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

			holdAnchor(state.getAt(0), new Vector2D(150, 150));
			//holdAnchor(state.getAt(0), new Vector2D(mouseX, mouseY));

		}


		public function evaluate(initial:State, t:Number, dt:Number, inputDerivatives:DerivativeHolder):DerivativeHolder {
			var outputDerivatives:DerivativeHolder = new DerivativeHolder();

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
				force = SpringNode.calculateForce(force, dest, source, -100.0, spring.naturalDistance[i], relVel);
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
