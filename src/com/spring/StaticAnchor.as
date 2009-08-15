package com.spring {
	import com.rk4.Vector2D;


	public class StaticAnchor implements IAnchor {
		public var pos:Vector2D;
		public var node:SpringNode;
		public var anchorPos:Vector2D;

		public function StaticAnchor(node:SpringNode) {
			this.node = node;
			anchorPos = node.pos.clone();
		}

		public function holdAnchor():void {
			node.pos = anchorPos.clone();
		}

	}
}