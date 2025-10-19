package undertale.overworld;

import flixel.FlxSprite;

class SavePoint extends InteractableSprite
{
    override public function new(X:Float, Y:Float, player:OverworldCharacter)
    {
        super(X,Y, player);

        loadGraphic(Paths.image("overworld/utSave"));
        loadGraphic(Paths.image("overworld/utSave"), true, Math.floor(width / 2), Math.floor(height));
        updateHitbox();
        animation.add("idle", [0, 1], 6, true);
        animation.play("idle");
    }
}