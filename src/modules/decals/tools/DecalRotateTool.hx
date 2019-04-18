package modules.decals.tools;

// TODO #10 -01010111
class DecalRotateTool extends DecalTool
{

	public var firstChange:Bool = false;
	public var rotating:Bool = false;
	public var origin:Vector;
	public var start:Vector;
	public var last:Vector;
	public var decals:Array<Decal>;

	override public function onMouseDown(pos:Vector)
	{
		decals = layerEditor.selected;
		if (decals.length == 0) return;
		origin = new Vector();
		for (decal in decals)
		{
			origin.x += decal.position.x;
			origin.y += decal.position.y;
		}
		origin.x /= decals.length;
		origin.y /= decals.length;

		pos.clone(start);
		pos.clone(last);

		rotating = true;
		firstChange = false;
		EDITOR.locked = true;
		EDITOR.overlayDirty();
	}

	override public function onMouseUp(pos:Vector)
	{
		rotating = false;
		EDITOR.locked = false;
		EDITOR.overlayDirty();
	}

	override public function onMouseMove(pos:Vector)
	{
		if (!rotating) return;
		if (pos.equals(last)) return;
		if (!firstChange)
		{
			firstChange = true;
			EDITOR.level.store('rotate decals');
		}
		var angle = Calc.angleTo(origin, pos);
		var initial = Calc.angleTo(origin, start);
		//for (decal in decals) decal.rotate(angle - initial);
		EDITOR.dirty();
		pos.clone(last);
	}

	// TODO #2 -01010111
	/*override public function onRightDown(pos:Vector)
	{
		for (decal in layer.decals.getGroup(layerEditor.selection)) decal.rotate(-decal.rotation);
	}*/

	override public function drawOverlay()
	{
		if (!rotating) return;
		var at = Calc.angleTo(origin, start);

		// Line to start
		{
			var vec = Vector.fromAngle(at, 80 / EDITOR.level.zoom);
			vec.x += origin.x;
			vec.y += origin.y;

			EDITOR.overlay.drawLine(origin, vec, Color.white);
			EDITOR.overlay.drawLineNode(origin, 10 / EDITOR.level.zoom, Color.green);
		}

		// Curve
		{
			var length = 60 / EDITOR.level.zoom;
			var move = 10 * Calc.DTR;
			var angle = Calc.angleTo(origin, last);
			var last = Vector.fromAngle(at, length);
			last.x += origin.x;
			last.y += origin.y;
			var vec = new Vector();

			while (Math.abs(Calc.angleDiff(at, angle)) > 0.1 * Calc.DTR)
			{
				at = Calc.angleApproach(at, angle, move);
				Vector.fromAngle(at, length, vec);
				vec.x += origin.x;
				vec.y += origin.y;

				EDITOR.overlay.drawLine(last, vec, Color.white);
				vec.clone(last);
			}

			// Line to mouse
			EDITOR.overlay.drawLine(origin, last, Color.green);
		}
	}

	override public function getIcon():String return 'decal-rotate';
	override public function getName():String return 'Rotate';

}