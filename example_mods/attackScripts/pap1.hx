var box = null;
var heart = null;
function initAttack(b, h)
{   
    box = b;
    heart = h;
    box.boxWidth = 300;
    box.updateBoxSize();
}

function startAttack()
{
    var loop = 0;
    startTimer(1, function(tmr:FlxTimer)
    {
        makeBoneBottom(box.x+box.width, -100, 40+(10*loop));
        loop++;
    }, 3);

    startTimer(6, function(tmr:FlxTimer)
    {
        end();
    }, 1);
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
    var boneB = makeBone(x, box.y, velX, 0, height);
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