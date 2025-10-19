package undertale;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

using StringTools;

class UTText extends FlxText
{
    public var defX:Float = 0;
    public var defY:Float = 0;
    override public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
    {
        super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
        shader = new TextShader();
    }
}

typedef UTTextFormat = 
{
    var startIndex:Int;
    var endIndex:Int;
    var color:FlxColor;
}

class UTTypedText extends FlxSpriteGroup
{
    public var text(default, set):String = "";
    public var font:String = "";
    public var size:Int = 8;
    public var fieldWidth:Float = 0;
    public var textGapAdd:Float = -4;
    private function set_text(value:String)
    {
        if (text != value)
        {
            if (value.contains(text)) //probably added text
            {
                var textToAdd = value.substring(text.length);
                for (i in textToAdd.split(""))
                    addText(i);
            }
            else
                generateText(value);
        }
        return text = value;
    }

    var textFormats:Array<UTTextFormat> = [];
    public function setTextFormats(a:Array<UTTextFormat>)
    {
        textFormats = a;
    }
    private function applyTextFormat(letter:UTText, index:Int)
    {
        if (textFormats.length == 0)
            return;

        for (i in textFormats)
        {
            if (index >= i.startIndex && index <= i.endIndex)
            {
                letter.color = i.color;
                return;
            }
        }
    }


    override public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
    {
        super(X, Y);
        fieldWidth = FieldWidth;
        size = Size;
        if (Text != null)
            text = Text;
    }

    var curX:Float = 0;
    var curY:Float = 0;
    function generateText(t:String)
    {
        for (i in members)
            i.destroy();
        clear();
        curX = 0;
        curY = 0;
        for (i in t.split(""))
        {
            addText(i);
        }
    }

    function addText(l:String)
    {
        var ignore:Bool = false;
        if (l == "#")
            ignore = true; //ignore hashtags to act as a pause
        var text = new UTText(curX, curY, 0, l, size);
        text.font = font;
        text.color = color;
        applyTextFormat(text, members.length);
        text.defX = curX;
        text.defY = curY;
        if (!ignore)
            curX += text.width+textGapAdd;
        if (l == "\n")
        {
            curX = 0;
            curY += size;
        }
        add(text);
        if (ignore)
            text.visible = false;
    }

    public var shake:Float = 0;
    public var shakeTime:Float = 0.035;

    var elapsedTime:Float = 0;
    public function updateShake(elapsed:Float)
    {
        elapsedTime += elapsed;
        if (elapsedTime >= shakeTime)
        {
            elapsedTime -= shakeTime;
            //trace('shake');
            for (i in members)
            {
                i.offset.x = FlxG.random.float(-shake, shake);
                i.offset.y = FlxG.random.float(-shake, shake);
            }
        }
    }
}