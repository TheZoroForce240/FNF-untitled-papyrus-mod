package undertale;

import flixel.math.FlxMath;
import lime.math.Vector2;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.geom.Point;
import flixel.math.FlxMatrix;
import flixel.math.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxCollision;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;

class PlayerHeart extends FlxSprite
{
    var box:BattleBox;

    private var hitbox:FlxSprite;
    public var movement:HeartMovement;
    public var soulMode(default, set):String = "";
    function set_soulMode(value:String):String
    {
        soulMode = value;
        movement.onChangeSoulMode();
        return soulMode;
    }

    var hp:Float = 92;
    public var maxHP:Float = 40;

    //deprecated stuff from older version, now moved into the movement class
    @:deprecated
    public var blue(default, set):Bool = false;
    private function set_blue(value:Bool):Bool 
    {
        blue = value;
        if (value)
            soulMode = "blue";
        else 
            soulMode = "default";
        return value;
    }
    @:deprecated
    public var blueGravityDir(get, set):Int;
    private function set_blueGravityDir(value:Int) { return movement.blueGravityDir = value; } //to stop breaking older scripts
    private function get_blueGravityDir() { return movement.blueGravityDir; }
    @:deprecated
    public var gravityAdd(get, set):Float;
    private function set_gravityAdd(value:Float) { return movement.gravityAdd = value; }
    private function get_gravityAdd() { return movement.gravityAdd; }

    public function new(box:BattleBox)
    {
        this.box = box;
       
        super(); //remember to only load graphic after super lol
        loadGraphic(Paths.image('ut/heart'));
        scale.set(1.5, 1.5);
        updateHitbox();
        hitbox = new FlxSprite();
        hitbox.makeGraphic(12, 12);
        hitbox.visible = false;

        if (box != null)
        {
            //center heart
            x = box.x + (box.width*0.5);
            x -= width*0.5;
            y = box.y + (box.height*0.5);
            y -= height*0.5;
        }


        movement = new HeartMovement(this);

        soulMode = "default";
    }
    override public function update(elapsed:Float)
    {
        if (box != null)
        {
            movement.update(elapsed);
            boundHeartToBox();
    
            hitbox.x = x + (width*0.5) - (hitbox.width*0.5);
            hitbox.y = y + (height*0.5) - (hitbox.height*0.5);
    
            //iframes stuff
            if (currentIFrames > 0)
            {
                currentIFrames -= elapsed;
            }
            else 
            {
                currentIFrames = 0;
                canTakeDamage = true;
            }
    
            checkAttacks(!(movement.xMove == 0 && movement.yMove == 0));
        }

        super.update(elapsed);
    }
    function boundHeartToBox()
    {
        var heartX = x;
        var heartY = y;
        if (box.angle != 0)
        {
            //scuffed ass circle collision
            var halfX = (box.width*0.5);
            var halfY = (box.height*0.5);

            var boxCenterX = box.x+halfX;
            var boxCenterY = box.y+halfY;
            var heartCenterX = x+(width*0.5);
            var heartCenterY = y+(height*0.5);
            var angToBoxCenter = Math.atan2(heartCenterY-boxCenterY, heartCenterX-boxCenterX);
            
            //angToBoxCenter = angToBoxCenter+90;

            //angle = angToBoxCenter-90;

            var maxPosX = boxCenterX + Math.cos(angToBoxCenter)*halfX;
            var maxPosY = boxCenterY + Math.sin(angToBoxCenter)*halfY;
            var dist = Vector2.distance(new Vector2(heartCenterX, heartCenterY), new Vector2(boxCenterX, boxCenterY));
            

            if (Math.abs(dist) > halfX)
            {
                heartCenterX = maxPosX;
                heartCenterY = maxPosY;
            }

            x = heartCenterX-(width*0.5);
            y = heartCenterY-(height*0.5);

            //cant figure this out lol
            /*
            var mat = new FlxMatrix();
            mat.identity();
            //mat.translate(-box.origin.x+box.x, -box.origin.y+box.y); //for some reason this get ignored
            mat.rotate(-box.angle*FlxAngle.TO_RAD);
            //mat.translate(box.origin.x-box.x, box.origin.y-box.y);
            var boxPos = mat.transformPoint(new Point(box.x, box.y));
            var heartPos = mat.transformPoint(new Point(heartX, heartY));


            //var rotatedRect:FlxRect = new FlxRect(box.x, box.y, box.width, box.height);
            //rotatedRect = rotatedRect.getRotatedBounds(box.angle, new FlxPoint(0.5, 0.5));

            //var heartRect:FlxRect = new FlxRect(x, y, width, height);
            //heartRect = heartRect.getRotatedBounds(box.angle, new FlxPoint(0.5, 0.5));

            //heartPos = mat.transformPoint(heartPos);
            //x = heartPos.x;
            //y = heartPos.y;

            //var collisionOffsetX = Math.sin(-box.angle*FlxAngle.TO_RAD)*width;
            //var collisionOffsetY = Math.cos(-box.angle*FlxAngle.TO_RAD)*height;

            if (heartPos.x < boxPos.x)
                heartPos.x = boxPos.x;
            if (heartPos.x+width > boxPos.x+box.width)
                heartPos.x = boxPos.x+box.width-width;
            if (heartPos.y < boxPos.y)
                heartPos.y = boxPos.y;
            if (heartPos.y+height > boxPos.y+box.height)
            {
                heartPos.y = boxPos.y+box.height-height;
            }

            mat.invert();
            //mat.identity();
            //mat.translate(box.origin.x, box.origin.y);
            //mat.rotate(box.angle*FlxAngle.TO_RAD);
            //mat.translate(box.origin.x, box.origin.y);
            heartPos = mat.transformPoint(new Point(heartPos.x, heartPos.y));
            //heartPos.x += width;

            x = heartPos.x;
            y = heartPos.y;
            */
        }
        else 
        {
            //default aabb collision
            if (heartX < box.x)
                heartX = box.x;
            if (heartX+width > box.x+box.width)
                heartX = box.x+box.width-width;
            if (heartY < box.y)
                heartY = box.y;
            if (heartY+height > box.y+box.height)
            {
                heartY = box.y+box.height-height;
            }

            x = heartX;
            y = heartY;
        }
    }
    override public function draw()
    {
        super.draw();
        if (hitbox.visible)
            hitbox.draw();
    }

    private function checkAttacks(didMove:Bool = false)
    {
        if (!canTakeDamage)
            return;
        if (box.attacks != null)
        {
            box.attacks.forEachAlive(function(attack:AttackObject){
                //attack.clipRect = new FlxRect(Math.min(box.x, 0), Math.min(box.y, 0), Math.max(box.x+box.width, attack.width), Math.max(box.y+box.height, attack.height));
                if (didMove && attack.orange)
                {
                    //do nothing if moving through orange
                }
                else if (((didMove && attack.blue) || !attack.blue) && attack.doesDamage) //hurt if you moved during blue or it isnt blue (so just normal attack)
                {
                    if (FlxCollision.pixelPerfectCheck(hitbox, attack.hitbox))
                    {
                        takeDamage(attack.damageToDeal, attack.iFramesAfterHit);
                        if (attack.destroyOnTouch)
                        {
                            attack.kill();
                            attack.active = false;
                            attack.visible = false;
                        }
                        //attack.hitbox.visible = true;
                    }
                }
                if (box.playerAttacks != null)
                {
                    box.playerAttacks.forEachAlive(function(playerAttack:AttackObject)
                    {
                        if (FlxCollision.pixelPerfectCheck(playerAttack.hitbox, attack.hitbox))
                        {
                            if (playerAttack.onHit != null)
                                playerAttack.onHit(attack);
                            if (attack.onHit != null)
                                attack.onHit(playerAttack);
                        }
                    });
                }
            });
        }
    }
    private var currentIFrames:Float = 0;
    private var canTakeDamage:Bool = true;
    public var onDamage:Float->Void = null;
    public function takeDamage(damage:Float, iFrames:Float)
    {
        canTakeDamage = false;
        hp -= damage;
        currentIFrames = iFrames;
        if (onDamage != null)
            onDamage(damage);
        FlxG.sound.play(Paths.sound("snd_hurt1"));
        //trace(hp);
    }

    @:allow(undertale.HeartMovement)
    private function checkIsOnGround(dir:Int = 0):Bool
    {
        var onPlat = false;
        if (box.platforms != null)
        {
            box.platforms.forEachAlive(function(plat:Platform){
                switch(dir)
                {
                    case 0: 
                        if (y+height >= plat.y && y+height <= plat.y+plat.height && (x+width >= plat.x && x <= plat.x+plat.width))
                            onPlat = true;
                    case 1: 
                        //return x <= plat.x;
                    case 2: 
                        //return y <= plat.y;
                        if (y <= plat.y+plat.height && y >= plat.y && (x+width >= plat.x && x <= plat.x+plat.width))
                            onPlat = true;
                    case 3:
                        //return x+width >= plat.x+plat.width;
                }
            });
        }
        if (onPlat)
            return true;
        switch(dir)
        {
            case 0: 
                return y+height >= box.y+box.height;
            case 1: 
                return x <= box.x;
            case 2: 
                return y <= box.y;
            case 3:
                return x+width >= box.x+box.width;
        }
        return false;
    }
}