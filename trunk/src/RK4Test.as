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

		// SPRING 
		public static const TOTAL_NODES:Number = 2;

		public function RK4Test() {
			stage.frameRate = 60;

			debugText = new TextField();
			addChild(debugText);

			currentState = new State();
			prevState = new State();

			createString();

			prevTime = getTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		protected function createString():void {
			var distance:Number = 20.0;

			// Create the springs in a row
			for (var i:int = 0; i < TOTAL_NODES; i++) {
				var springNode:SpringNode = new SpringNode();
				springNode.pos = new Vector2D((stage.stageWidth / 2) + i * (distance), 100);
				currentState.springs.push(springNode);
			}

			// Connect first spring
			currentState.springs[0].neighbors.push(currentState.springs[1]);
			currentState.springs[0].naturalDistance.push(distance);

			// Connect last spring
			currentState.springs[TOTAL_NODES - 1].neighbors.push(currentState.springs[TOTAL_NODES - 2]);
			currentState.springs[TOTAL_NODES - 1].naturalDistance.push(distance * 2);

			// Connect the nodes
			for (var j:int = 1; j < TOTAL_NODES - 1; j++) {
				currentState.springs[j].neighbors.push(currentState.springs[j - 1]);
				currentState.springs[j].naturalDistance.push(distance * 2);

				currentState.springs[j].neighbors.push(currentState.springs[j + 1]);
				currentState.springs[j].naturalDistance.push(distance * 2);
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

				var currentSpring:SpringNode = state.getAt(i);
				currentSpring.pos = currentSpring.pos.add(dxdt.multiplyScalar(dt));
				currentSpring.momentum = currentSpring.momentum.add(dpdt.multiplyScalar(dt));

				// assuming unitn mass
				//currentSpring.vel = currentSpring.momentum;
			}


			/* 			for (var i:Number = 1; i < TOTAL_NODES; i++) {
			   var spring:SpringNode = state.getAt(i);

			   // Here we do a simple Euler Integratioin
			   spring.pos = spring.pos.add(spring.vel.multiplyScalar(dt));

			   // vel = vel + acceleration
			   spring.vel = spring.vel.add(calcSingleForce(spring, t, dt).multiplyScalar(SpringNode.MASS).multiplyScalar(dt));


			   // momentum(p) = mass * velocity
			   // also dp/dt = f
			   //spring.momentum = spring.vel.multiplyScalar(SpringNode.MASS);

			   // vel = momentum / mass
			   //spring.vel = spring.momentum.multiplyScalar(SpringNode.INVERSE_MASS);
			 } */

			// The anchor point should not move			
			//state.getAt(0).pos = new Vector2D(mouseX, mouseY); //SpringAnchor(state.anchors[0]).pos;
			state.getAt(0).pos = SpringAnchor(state.anchors[0]).pos;
			state.getAt(0).momentum.zero();
			state.getAt(0).vel.zero();


		/*  			var lastSpringIndex:int = state.springs.length - 1;
		   var midSpringIndex:int = state.springs.length / 2;

		   state.getAt(midSpringIndex).pos = new Vector2D(mouseX + 50, mouseY); //SpringAnchor(state.anchors[0]).pos;
		   state.getAt(midSpringIndex).momentum.zero();
		   state.getAt(midSpringIndex).vel.zero();

		   state.getAt(lastSpringIndex).pos = new Vector2D(mouseX + 100, mouseY); //SpringAnchor(state.anchors[0]).pos;
		   state.getAt(lastSpringIndex).momentum.zero();
		 state.getAt(lastSpringIndex).vel.zero();  */
		}


		public function evaluate(initial:State, t:Number, dt:Number, inputDerivatives:DerivativeHolder):DerivativeHolder {
			var outputDerivatives:DerivativeHolder = new DerivativeHolder();

			for (var i:Number = 0; i < TOTAL_NODES; i++) {
				var spring:SpringNode = initial.getAt(i);
				var derivative:Derivative = inputDerivatives.getAt(i);

				// Here we do a simple Euler Integratioin
				var newSpring:SpringNode = new SpringNode();
				newSpring.pos = spring.pos.add(derivative.vel.multiplyScalar(dt));
				newSpring.momentum = spring.momentum.add(derivative.force.multiplyScalar(dt));

				newSpring.neighbors = spring.neighbors.concat();
				newSpring.naturalDistance = spring.naturalDistance.concat();

				var derivativeOut:Derivative = new Derivative();
				derivativeOut.force = calcSingleForce(newSpring, t, dt);
				derivativeOut.vel = newSpring.momentum.multiplyScalar(SpringNode.INVERSE_MASS);

				outputDerivatives.setAt(i, derivativeOut);
			}



			return outputDerivatives;
		}


		public function calcSingleForce(spring:SpringNode, t:Number, dt:Number):Vector2D {
			var result:Vector2D = new Vector2D();
			var source:Vector2D = new Vector2D();
			var dest:Vector2D = new Vector2D();
			var force:Vector2D = new Vector2D;
			var naturalDistance:Number;
			source = spring.pos.clone();

			for (var i:Number = 0; i < spring.neighbors.length; i++) {
				var neighbor:SpringNode = spring.neighbors[i];

				dest = neighbor.pos.clone();

				var relVel:Vector2D = spring.vel.subtract(neighbor.vel);
				debugText.text = neighbor.vel.toString() + "\n";
				debugText.text += spring.vel.toString() + "\n";
				debugText.text += relVel.toString() + "\n";

				force = SpringNode.calculateForce(force, dest, source, -50.0, naturalDistance, relVel);

				result = result.add(force);
			}

			// Apply gravity
			//result = result.add(new Vector2D(0, 300));
			return result;
		}

	}
}
