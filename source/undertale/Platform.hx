package undertale;

import flixel.FlxSprite;

class Platform extends FlxSprite
{
    public var hitbox:FlxSprite;

    public function new(X:Float = 0, Y:Float = 0)
    {
        super(X, Y);
        //loadGraphic(Paths.image('ut/bones/spr_s_bonewall_wide'));
        makeGraphic(300, 30);
        //scale.set(2, 2);
        //updateHitbox();
        hitbox = new FlxSprite();
        hitbox.makeGraphic(Std.int(width), Std.int(height));
        hitbox.visible = false;
    }
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
    override public function draw()
    {
        super.draw();
        if (hitbox.visible)
            hitbox.draw();
    }
}