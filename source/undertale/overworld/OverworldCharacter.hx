package undertale.overworld;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;

class OverworldCharacter extends FlxSprite
{
    final directionNames:Array<String> = ["up", "right", "down", "left"];
    final directionX:Array<Int> = [0, 1, 0, -1];
    final directionY:Array<Int> = [-1, 0, 1, 0];

    public var moving:Bool = false;
    public var player:Bool = false;
    public var direction:Int = 0;
    public var speed:Float = 120;

    public var interactHitbox:FlxObject;

    override public function new(X:Float, Y:Float, character:String, startDir:Int = 0)
    {
        super(X, Y);
        antialiasing = false;
        direction = startDir;
        loadCharacter(character);
    }

    public function loadCharacter(name:String)
    {
        frames = Paths.getSparrowAtlas("overworld/"+name);

        for (i in directionNames)
        {
            animation.addByPrefix(i+"0", i+"0", 8, true);
            animation.addByPrefix(i+"Idle", i+"Idle", 8, true);
        }
        animation.play(directionNames[direction]+"Idle");

        //scale.set(3, 3);
        updateHitbox();
        offset.y += height*0.6;
        height *= 0.4;

        interactHitbox = new FlxObject(0, 0, width*1.2, height*1.2);
    }

    var holdingDir:Bool = false;
    public var ignoreAnims:Bool = false;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        interactHitbox.x = x + width*0.5 - interactHitbox.width*0.5;
        interactHitbox.y = y + height*0.5 - interactHitbox.height*0.5;

        if (player)
        {
            //set up a little weirdly so you can do the frisk dance lol
            if (PlayerControls.RIGHT && direction != 1)
            {
                if (direction == 2 || direction == 0)
                    moveInDirection(direction); //move at correct speed diagonally
                direction = 1;
                moveInDirection(direction);
                return;
            }
            if (PlayerControls.LEFT && direction != 3)
            {
                if (direction == 2 || direction == 0)
                    moveInDirection(direction);
                direction = 3;
                moveInDirection(direction);
                return;
            }
            if (PlayerControls.DOWN && direction != 2)
            {
                if (direction == 3 || direction == 1)
                    moveInDirection(direction);
                direction = 2;
                moveInDirection(direction);
                return;
            }
            if (PlayerControls.UP && direction != 0)
            {
                if (direction == 3 || direction == 1)
                    moveInDirection(direction);
                direction = 0;
                moveInDirection(direction);
                return;
            }



            if (!(PlayerControls.UP || PlayerControls.LEFT || PlayerControls.RIGHT || PlayerControls.DOWN))
            {
                if (!ignoreAnims)
                    animation.play(directionNames[direction]+"Idle");
                holdingDir = false;
            }
            else 
            {
                moveInDirection(direction);
            }
        }
        else 
        {

            if (moving)
            {
                moveInDirection(direction);
            }
            else 
            {
                if (!ignoreAnims)
                    animation.play(directionNames[direction]+"Idle");
            }
        }
    }

    function moveInDirection(dir:Int)
    {
        x += directionX[dir]*speed*FlxG.elapsed;
        y += directionY[dir]*speed*FlxG.elapsed;
        if (!ignoreAnims)
            animation.play(directionNames[dir]+"0");
    }
}