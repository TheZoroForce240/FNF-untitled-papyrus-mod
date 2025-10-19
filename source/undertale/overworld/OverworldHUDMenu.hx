package undertale.overworld;

import flixel.group.FlxSpriteGroup;

class OverworldHUDMenu extends FlxSpriteGroup
{
    var instance:OverworldState;
    override public function new(instance:OverworldState)
    {
        super();
        this.instance = instance;
    }
}