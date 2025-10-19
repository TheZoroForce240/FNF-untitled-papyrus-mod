package undertale;

import flixel.FlxSprite;

class AttackObject extends FlxSprite
{
    public var hitbox:FlxSprite;
    public var damageToDeal:Float = 3;
    public var iFramesAfterHit:Float = 1.5;

    public var blue:Bool = false;
    public var orange:Bool = false;
    public var name:String = "";
    public var doesDamage = true;
    public var destroyOnTouch:Bool = true;

    public var onHit:AttackObject->Void;

    public function new(X:Float = 0, Y:Float = 0, blue:Bool = false, orange:Bool = false, spriteName:String = 'ut/bones/spr_s_bonewall_wide')
    {
        super(X, Y);
        hitbox = new FlxSprite();
        loadGraphic(Paths.image(spriteName));
        scale.set(1.5, 1.5);
        updateHitbox();
        
        //hitbox.makeGraphic(Std.int(width), Std.int(height));
        //hitbox.visible = false;

        if (blue)
        {
            this.color = 0xFF08A9FF;
            this.blue = true;
        }
        else if (orange)
        {
            this.color = 0xFFFFA040;
            this.orange = true;
        }

        onHit = function(attack:AttackObject)
        {
            visible = false;
            active = false;
            kill();
        };
    }
    public var hitboxFollowSprite = true;
    override public function update(elapsed:Float)
    {
        if (hitboxFollowSprite)
        {
            hitbox.x = x;
            hitbox.y = y;
            hitbox.angle = angle;
        }

        if (blue)
            color = 0xFF08A9FF;
        if (orange)
            color = 0xFFFFA040;
        //hitbox.scale.x = scale.x;
        //hitbox.scale.y = scale.y;
        //hitbox.origin.x = origin.x;
        //hitbox.origin.y = origin.y;
        //hitbox.width = width;
        //hitbox.height = height;
        super.update(elapsed);
    }
    override public function draw()
    {
        super.draw();
        //hitbox.visible = true;
        if (hitbox.visible)
            hitbox.draw();
    }
    override public function updateHitbox()
    {
        super.updateHitbox();
        hitbox.makeGraphic(Std.int(width), Std.int(height)); //update the "actual" hitbox lol
        hitbox.visible = false;
    }
}