package undertale;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class UndertaleBox extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    var left:FlxSprite;
    var top:FlxSprite;
    var right:FlxSprite;
    var bottom:FlxSprite;
    var edgeWidth = 8;
    override public function new(boxW:Int, boxH:Int)
    {
        super();

        

        bg = new FlxSprite(0, 0);
        bg.makeGraphic(boxW, boxH, 0xFF000000);

        add(bg);

        top = new FlxSprite(0,0).makeGraphic(boxW, edgeWidth);
        add(top);
        bottom = new FlxSprite(0,boxH-edgeWidth).makeGraphic(boxW, edgeWidth);
        add(bottom);
        left = new FlxSprite(0,edgeWidth).makeGraphic(edgeWidth, boxH-(edgeWidth*2));
        add(left);
        right = new FlxSprite(boxW-edgeWidth,edgeWidth).makeGraphic(edgeWidth, boxH-(edgeWidth*2));
        add(right);
    }

    override public function updateHitbox()
    {
        

        bg.setGraphicSize(Std.int(width), Std.int(height));
        bg.updateHitbox();

        top.setGraphicSize(Std.int(width), Std.int(edgeWidth));
        top.updateHitbox();

        bottom.setGraphicSize(Std.int(width), Std.int(edgeWidth));
        bottom.updateHitbox();
        bottom.y = y + (Std.int(height)-edgeWidth);

        left.setGraphicSize(Std.int(edgeWidth), Std.int(height-(edgeWidth*2)));
        left.updateHitbox();
        left.y = y + edgeWidth;

        right.setGraphicSize(Std.int(edgeWidth), Std.int( height-(edgeWidth*2)));
        right.updateHitbox();
        right.x = x + (width-edgeWidth);
        right.y = y + edgeWidth;

        //super.updateHitbox();
    }
}