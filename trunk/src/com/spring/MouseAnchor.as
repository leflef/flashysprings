package com.spring {
	import com.rk4.Vector2D;

	import flash.display.DisplayObject;

	/**
	 * Anchors a node using a mouse position with an offset
	 *
	 */
	public class MouseAnchor implements IAnchor {
		protected var _node:SpringNode;
		protected var _mouseArea:DisplayObject;
		protected var _offset:Vector2D;

		public function MouseAnchor(node:SpringNode, displayObject:DisplayObject, offset:Vector2D = null) {
			_offset = (offset != null) ? offset : new Vector2D();
			_node = node;
			_mouseArea = displayObject;
		}

		public function set mouseArea(value:DisplayObject):void {
			_mouseArea = value;
		}

		public function holdAnchor():void {
			_node.pos = new Vector2D(_offset.x + _mouseArea.stage.mouseX, _offset.y + _mouseArea.stage.mouseY);
		}
	}
}