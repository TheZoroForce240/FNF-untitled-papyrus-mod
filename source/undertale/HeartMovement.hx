package undertale;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class HeartMovement extends FlxBasic implements IFlxDestroyable
{
    //movement this frame
    public var xMove:Float = 0;
    public var yMove:Float = 0;

    public var speed:Float = 200;

    //blue soul stuff/////////
    private var blueGravityTime:Float = 0;
    static var gravityStrength:Float = 2.7;
    static var jumpStrength:Float = 1.8;
    static var falloffSpeed:Float = 30;
    static var fallSpeedIncrease:Float = 3;
    public var blueGravityDir(default, set):Int = 0; //down, left, up, right
    private function set_blueGravityDir(value:Int):Int 
    {
        blueGravityDir = value;
        setupHeartAngle();
        return value;
    }
    public var gravityAdd:Float = 0;
    private final DOWN:Int = 0;
    private final LEFT:Int = 1;
    private final UP:Int = 2;
    private final RIGHT:Int = 3;
    //////////////////////////////



    var heart:PlayerHeart;
    public function new(heart:PlayerHeart)
    {
        super();
        this.heart = heart;
        setupHeartColor();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        xMove = 0;
        yMove = 0;
        switch(heart.soulMode)
        {
            case "blue":  //blue soul movement
                /*
                if (controls.UP)
                {
                    if (checkIfCanMoveToTheSide(UP))
                        yMove = -1;
                    else 
                        tryJump(UP);
                }
                if (controls.LEFT)
                {
                    if (checkIfCanMoveToTheSide(LEFT))
                        xMove = -1;
                    else 
                        tryJump(LEFT);
                }
                if (controls.RIGHT)
                {
                    if (checkIfCanMoveToTheSide(RIGHT))
                        xMove = 1;
                    else 
                        tryJump(RIGHT);
                }
                if (controls.DOWN)
                {
                    if (checkIfCanMoveToTheSide(DOWN))
                        yMove = 1;
                    else 
                        tryJump(DOWN);
                }


                if (!heart.checkIsOnGround(blueGravityDir) || blueGravityTime > 0.0)
                {

                    //if (blueGravityTime > -1.0) 
                    //{
                        blueGravityTime -= elapsed*blueGravityTime*1.0;
                        if (!getDirControl() && blueGravityTime > 2.4) //stop if let go
                            blueGravityTime = 2.4; //slow down faster

                        if (blueGravityTime < 2.0)
                            blueGravityTime -= elapsed*blueGravityTime*1.0;
                    //}
                    trace(blueGravityTime);
                    yMove = applyGravityY(yMove, -blueGravityTime);
                    xMove = applyGravityX(xMove, -blueGravityTime);

                    var gravityAmount = 2.0 + gravityAdd;
                    yMove = applyGravityY(yMove, gravityAmount);
                    xMove = applyGravityX(xMove, gravityAmount);
                }*/

                //if (heart.checkIsOnGround(blueGravityDir))
                    //blueGravityTime = 0;

                

                if (!heart.checkIsOnGround(blueGravityDir))
                {
                    blueGravityTime += gravityStrength*elapsed;
                }

                var isJumping = false;

                if (PlayerControls.UP)
                {
                    if (checkIfCanMoveToTheSide(UP))
                        yMove = -1;
                    else 
                        if (tryJump(UP))
                        {
                            isJumping = true;
                            //yMove = -1;
                        }
                }
                if (PlayerControls.LEFT)
                {
                    if (checkIfCanMoveToTheSide(LEFT))
                        xMove = -1;
                    else 
                        if (tryJump(LEFT))
                        {
                            isJumping = true;
                            //xMove = -1;
                        }
                }
                if (PlayerControls.RIGHT)
                {
                    if (checkIfCanMoveToTheSide(RIGHT))
                        xMove = 1;
                    else 
                        if (tryJump(RIGHT))
                        {
                            isJumping = true;
                            //xMove = 1;
                        }
                }
                if (PlayerControls.DOWN)
                {
                    if (checkIfCanMoveToTheSide(DOWN))
                        yMove = 1;
                    else 
                        if (tryJump(DOWN))
                        {
                            isJumping = true;
                            //yMove = 1;
                        }
                }

                if (blueGravityTime < 0.0)
                {
                    if (!isJumping)
                        blueGravityTime -= elapsed*blueGravityTime*falloffSpeed;
                }
                else 
                {
                    blueGravityTime += elapsed*blueGravityTime*fallSpeedIncrease;
                }

                //trace(blueGravityTime);
                if (blueGravityTime != 0)
                {
                    yMove = applyGravityY(yMove, blueGravityTime);
                    xMove = applyGravityX(xMove, blueGravityTime);
                }

                var debug = false;

                if (debug)
                {

                    if (FlxG.keys.justPressed.P)
                        jumpStrength += 0.1;
                    if (FlxG.keys.justPressed.O)
                        jumpStrength -= 0.1;
                    if (FlxG.keys.justPressed.P || FlxG.keys.justPressed.O)
                        trace(jumpStrength);
                    if (FlxG.keys.justPressed.U)
                        gravityStrength += 0.1;
                    if (FlxG.keys.justPressed.I)
                        gravityStrength -= 0.1;
                    if (FlxG.keys.justPressed.U || FlxG.keys.justPressed.I)
                        trace(gravityStrength);
                }

            case "default": 
                if (PlayerControls.UP)
                    yMove = -1;
                if (PlayerControls.LEFT)
                    xMove = -1;
                if (PlayerControls.RIGHT)
                    xMove = 1;
                if (PlayerControls.DOWN)
                    yMove = 1;
            case "yellow": 
                if (PlayerControls.UP)
                    yMove = -1;
                if (PlayerControls.LEFT)
                    xMove = -1;
                if (PlayerControls.RIGHT)
                    xMove = 1;
                if (PlayerControls.DOWN)
                    yMove = 1;
                if (PlayerControls.INTERACT_P)
                {
                    //shoot
                    
                }
        }
        heart.x += xMove*elapsed*speed;
        heart.y += yMove*elapsed*speed;

        switch(heart.soulMode)
        {
            case "blue": 
                if (heart.checkIsOnGround(blueGravityDir)) //need to check after moving
                    blueGravityTime = 0;
        }
    }

    override public function destroy()
    {
        heart = null;
        super.destroy();
    }

    public function onChangeSoulMode()
    {
        setupHeartColor();
    }

    private function setupHeartColor()
    {
        switch(heart.soulMode)
        {
            case "blue": 
                heart.color = 0xFF0836F3;
            case "default": 
                heart.color = FlxColor.RED;
        }
        setupHeartAngle();
    }

    public function setupHeartAngle()
    {
        heart.angle = 0;
        switch(heart.soulMode)
        {
            case "blue": 
                switch(blueGravityDir)
                {
                    case 1: 
                        heart.angle = 90;
                    case 2: 
                        heart.angle = 180;
                    case 3:
                        heart.angle = -90;
                }
        }
    }
   
    //some functions for blue soul mode////
    function checkIfCanMoveToTheSide(dir:Int)
    {
        if (blueGravityDir == DOWN || blueGravityDir == UP)
            if (dir == LEFT || dir == RIGHT)
                return true;
        if (blueGravityDir == LEFT || blueGravityDir == RIGHT)
            if (dir == DOWN || dir == UP)
                return true;
        return false;
    }
    function tryJump(dir:Int)
    {
        var doJump = false;
        switch(dir)
        {
            //check if youre pressing the opposite direction to the one youre at
            case 0: 
                doJump = blueGravityDir == UP;
            case 1: 
                doJump = blueGravityDir == RIGHT;
            case 2: 
                doJump = blueGravityDir == DOWN;
            case 3:
                doJump = blueGravityDir == LEFT;
        }
        if (doJump)
        {
            if (heart.checkIsOnGround(blueGravityDir))
                blueGravityTime = -jumpStrength;
        }
        return doJump;
    }
    function applyGravityY(yMove:Float, val:Float)
    {
        switch(blueGravityDir)
        {
            case 0: 
                yMove += val;
            case 2: 
                yMove -= val;
        }
        return yMove;
    }
    function applyGravityX(xMove:Float, val:Float)
    {
        switch(blueGravityDir)
        {
            case 1: 
                xMove -= val;
            case 3: 
                xMove += val;
        }
        return xMove;
    }
    function getDirControl() //get the control you use to jump
    {
        switch(blueGravityDir) 
        {
            case 0: 
                return PlayerControls.UP;
            case 1: 
                return PlayerControls.RIGHT;
            case 2: 
                return PlayerControls.DOWN;
            case 3:
                return PlayerControls.LEFT;
        }
        return false;
    }
    /////////////
}