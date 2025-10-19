var box = null;
var heart = null;
function initAttack(b, h)
{   
    box = b;
    heart = h;
    heart.blue = true;
    box.boxWidth = 400;
    box.updateBoxSize();
}

function startAttack()
{
    var loop = 0;
    startTimer(1.5, function(tmr:FlxTimer)
    {
        makeShit2(180);
    }, 3);

    startTimer(6, function(tmr:FlxTimer)
    {
        heart.blueGravityDir = 2;
        playSound("snd_tempbell");
    }, 1);

    startTimer(4.5, function(tmr:FlxTimer)
    {
        startTimer(1.5, function(tmr:FlxTimer)
            {
                makeShit3(180);
            }, 3);
    }, 1);



    startTimer(11, function(tmr:FlxTimer)
    {
        end();
    }, 1);
}

function makeShit(speed)
{
    var bot = makeBoneBottom(box.x-10, speed, 100);
    var top = makeBoneTop(box.x-10, speed, 100);
    startTween(bot, {boneHeight: 70}, 1.3, {ease: FlxEase.cubeInOut, onUpdate: function(t)
    {
        bot.y = (box.y+box.boxHeight)-bot.height;
    }});
    startTween(top, {boneHeight: 70}, 1.3, {ease: FlxEase.cubeInOut});

    var bot2 = makeBoneBottom(box.x+box.width, -speed, 100);
    var top2 = makeBoneTop(box.x+box.width, -speed, 100);
    startTween(bot2, {boneHeight: 70}, 1.3, {ease: FlxEase.cubeInOut, onUpdate: function(t)
    {
        bot2.y = (box.y+box.boxHeight)-bot2.height;
    }});
    startTween(top2, {boneHeight: 70}, 1.3, {ease: FlxEase.cubeInOut});
}
function makeShit2(speed)
{
    var bot = makeBoneBottom(box.x-10, speed, 150);
    startTween(bot, {boneHeight: 70}, 1.3, {ease: FlxEase.cubeInOut, onUpdate: function(t)
    {
        bot.y = (box.y+box.boxHeight)-bot.height;
    }});

    var bot2 = makeBoneBottom(box.x+box.width-5, -speed, 150);
    startTween(bot2, {boneHeight: 70}, 1.3, {ease: FlxEase.cubeInOut, onUpdate: function(t)
    {
        bot2.y = (box.y+box.boxHeight)-bot2.height;
    }});
}
function makeShit3(speed)
{
    var bot = makeBoneTop(box.x-10, speed, 150);
    startTween(bot, {boneHeight: 70}, 1.3, {ease: FlxEase.cubeInOut, onUpdate: function(t)
    {
        //bot.y = (box.y+box.boxHeight)-bot.height;
    }});

    var bot2 = makeBoneTop(box.x+box.width-5, -speed, 150);
    startTween(bot2, {boneHeight: 70}, 1.3, {ease: FlxEase.cubeInOut, onUpdate: function(t)
    {
        //bot2.y = (box.y+box.boxHeight)-bot2.height;
    }});
}

function makeBoneSet(velX, height)
{
    var bone = makeBone(box.x, box.y+box.boxHeight, velX, 0, height);
    bone.y -= bone.height;
    box.attacks.add(bone);

    var bone2 = makeBone(box.x+box.boxWidth, box.y+box.boxHeight, -velX, 0, height);
    bone2.x -= bone2.width;
    bone2.y -= bone2.height;
    box.attacks.add(bone2);
}

function makeBoneWallWithHole(x, velX, holeY, holeHeight)
{
    var boneT = makeBone(x, box.y, velX, 0, holeY);
    box.attacks.add(boneT);

    var boneB = makeBone(x, box.y+box.boxHeight, velX, 0, box.boxHeight - holeY - holeHeight);
    boneB.y -= boneB.height;
    box.attacks.add(boneB);
}

function makeBoneWave(x, velX, length, width, minHeight, maxHeight)
{
    for (i in 0...length)
    {
        var boneB = makeBone(x+(width*i), box.y+box.boxHeight, velX, 0, (Math.abs(Math.sin(((i)/(length+1))*4)) * (maxHeight-minHeight))+minHeight);
        boneB.y -= boneB.height;
        box.attacks.add(boneB);
    }
}

function makeBoneTop(x, velX, height)
{
    var boneB = makeBone(x, box.y+8, velX, 0, height-8);
    box.attacks.add(boneB);
    return boneB;
}

function makeBoneBottom(x, velX, height)
{
    var boneB = makeBone(x, box.y+box.boxHeight, velX, 0, height);
    boneB.y -= boneB.height;
    box.attacks.add(boneB);
    return boneB;
}