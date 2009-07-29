package {
	import com.rk4.RK4Sim;
	import com.rk4.State;
	import com.rk4.Vector2D;

	public class SpringTest extends RK4Sim {
		public var springs:Array; // Springs Binding The Masses (There Shall Be [numOfMasses - 1] Of Them)
		public var gravitation:Vector2D; // Gravitational Acceleration (Gravity Will Be Applied To All Masses)
		public var ropeConnectionPos:Vector2D; // A Point In Space That Is Used To Set The Position Of The 
		// First Mass In The System (Mass With Index 0)
		public var ropeConnectionVel:Vector2D; // A Variable To Move The ropeConnectionPos (By This, We Ccan Swing The Rope)
		public var groundRepulsionConstant:Number; // A Constant To Represent How Much The Ground Shall Repel The Masses
		public var groundFrictionConstant:Number; // A Constant Of Friction Applied To Masses By The Ground
		// (Used For Sliding Of Rope On The Ground)
		public var groundAbsorptionConstant:Number; // A Constant Of Absorption Friction Applied To Masses By The Ground
		// (Used For Vertical Collisions Of The Rope With The Ground)
		public var groundHeight:Number; // A Value To Represent The Y Value Of The Ground
		// (The Ground Is A Planer Surface Facing +Y Direction)
		public var airFrictionConstant;

		public function SpringTest() {
			gravitation = gravitation;
			airFrictionConstant = airFrictionConstant;
			groundFrictionConstant = groundFrictionConstant;
			groundRepulsionConstant = groundRepulsionConstant;
			groundAbsorptionConstant = groundAbsorptionConstant;
			groundHeight = groundHeight;

			// To Set The Initial Positions Of Masses Loop With For(;;)
			for (var a:uint = 0; a < numOfMasses; ++a) {
				masses[a].pos.x = a * springLength; // Set X-Position Of masses[a] With springLength Distance To Its Neighbor
				masses[a].pos.y = 0; // Set Y-Position As 0 So That It Stand Horizontal With Respect To The Ground
				masses[a].pos.z = 0; // Set Z-Position As 0 So That It Looks Simple
			}

			springs = new Spring * [numOfMasses - 1];
			// To Create Everyone Of Each Start A Loop
			for (a = 0; a < numOfMasses - 1; ++a) {
				// Create The Spring With Index "a" By The Mass With Index "a" And Another Mass With Index "a + 1".
				springs[a] = new Spring(masses[a], masses[a + 1], springConstant, springLength, springFrictionConstant);
			}
		}

		override protected function interpolate(alpha:Number):State {

		}

		override protected function render(state:State):void {

		}

		override protected function acceleration(state:State, t:Number, dt:Number):Vector2D {

		}

		// solve() Is Overriden Because We Have Forces To Be Applied
		public function solve():void {
			// Apply Force Of All Springs
			for (var a:uint = 0; a < numOfMasses - 1; ++a) {
				springs[a].solve(); // Spring With Index "a" Should Apply Its Force
			}

			// Start A Loop To Apply Forces Which Are Common For All Masses
			for (a = 0; a < numOfMasses; ++a) {
				masses[a].applyForce(gravitation * masses[a].m); // The Gravitational Force
				// The air friction
				masses[a].applyForce(-masses[a].vel * airFrictionConstant);

				/*
				   // Forces From The Ground Are Applied If A Mass Collides With The Ground
				   if (masses[a].pos.y < groundHeight) {
				   var v:Vector2D; // A Temporary Vector3D
				   v = masses[a].vel; // Get The Velocity
				   v.y = 0; // Omit The Velocity Component In Y-Direction
				   // The Velocity In Y-Direction Is Omited Because We Will Apply A Friction Force To Create
				   // A Sliding Effect. Sliding Is Parallel To The Ground. Velocity In Y-Direction Will Be Used
				   // In The Absorption Effect.
				   // Ground Friction Force Is Applied
				   masses[a].applyForce(-v * groundFrictionConstant);

				   v = masses[a].vel; // Get The Velocity
				   v.x = 0; // Omit The x And z Components Of The Velocity
				   // Above, We Obtained A Velocity Which Is Vertical To The Ground And It Will Be Used In
				   // The Absorption Force
				   // Let's Absorb Energy Only When A Mass Collides Towards The Ground
				   if (v.y < 0) {
				   // The Absorption Force Is Applied
				   masses[a].applyForce(-v * groundAbsorptionConstant);
				   }

				   // The Ground Shall Repel A Mass Like A Spring.
				   // By "Vector3D(0, groundRepulsionConstant, 0)" We Create A Vector In The Plane Normal Direction
				   // With A Magnitude Of groundRepulsionConstant.
				   // By (groundHeight - masses[a].pos.y) We Repel A Mass As Much As It Crashes Into The Ground.
				   var force:Vector2D = Vector3D(0, groundRepulsionConstant, 0) * (groundHeight - masses[a].pos.y);

				   masses[a].applyForce(force); // The Ground Repulsion Force Is Applied
				   }
				 */
			}
		}

		// simulate(float dt) Is Overriden Because We Want To Simulate
		// The Motion Of The ropeConnectionPos
		public function simulate(dt:Number):void {
			//Simulation::simulate(dt);					// The Super Class Shall Simulate The Masses

			ropeConnectionPos += ropeConnectionVel * dt; // Iterate The Positon Of ropeConnectionPos
			// ropeConnectionPos Shall Not Go Under The Ground
			if (ropeConnectionPos.y < groundHeight) {
				ropeConnectionPos.y = groundHeight;
				ropeConnectionVel.y = 0;
			}

			masses[0].pos = ropeConnectionPos; // Mass With Index "0" Shall Position At ropeConnectionPos
			masses[0].vel = ropeConnectionVel; // The Mass's Velocity Is Set To Be Equal To ropeConnectionVel
		}

		// The Method To Set ropeConnectionVel
		public function setRopeConnectionVel(ropeConnectionVel:Vector2D):void {
			this.ropeConnectionVel = ropeConnectionVel;
		}


	}
}