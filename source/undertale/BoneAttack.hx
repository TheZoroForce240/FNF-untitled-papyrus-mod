package undertale;

import flixel.FlxSprite;

class BoneAttack extends AttackObject
{
    public var top:FlxSprite;
    public var mid:FlxSprite;
    public var bottom:FlxSprite;

    public var boneHeight(default, set):Float = 300;
    function set_boneHeight(value:Float):Float 
    {
        setGraphicSize(Std.int(this.width), Std.int(value)); //automatically update
        updateHitbox();
		return boneHeight = value;
	}

    public function new(X:Float = 0, Y:Float = 0, blue:Bool = false, orange:Bool = false)
    {
        
        top = new FlxSprite(0,0).loadGraphic(Paths.image('ut/bones/boneBottom-pap'));
        top.scale.set(1.5,1.5);
        top.flipY = true;
        top.updateHitbox();
        mid = new FlxSprite(0,0).loadGraphic(Paths.image('ut/bones/boneMid-pap'));
        mid.scale.set(1.5,1.5);
        mid.updateHitbox();
        bottom = new FlxSprite(0,0).loadGraphic(Paths.image('ut/bones/boneBottom-pap'));
        bottom.scale.set(1.5,1.5);
        bottom.updateHitbox();

        super(X, Y, blue, orange);
        //visible = false;

        setGraphicSize(Std.int(mid.width), 100);
        updateHitbox();
    }
    override public function draw()
    {
        //super.draw();
        //hitbox.visible = true;
        if (hitbox.visible)
            hitbox.draw();

        top.x = x;
        top.y = y;
        mid.x = x;
        mid.y = y+(height*0.5);
        bottom.x = x;
        bottom.y = y+height-bottom.height;

        top.color = color;
        mid.color = color;
        bottom.color = color;

        mid.draw();
        top.draw();
        bottom.draw();
    }
    override public function updateHitbox()
    {
        super.updateHitbox();
        mid.setGraphicSize(Std.int(mid.width), Std.int(height)-10);
        hitbox.makeGraphic(Std.int(width), Std.int(height)); //update the "actual" hitbox lol
        hitbox.visible = false;
    }


}