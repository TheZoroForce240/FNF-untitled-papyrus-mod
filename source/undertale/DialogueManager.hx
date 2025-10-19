package undertale;

import flixel.util.FlxColor;
import undertale.UTText.UTTextFormat;
import undertale.UTText.UTTypedText;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;

using StringTools;

typedef DialogueData = 
{
    var text:String;
    var ?font:String;
    var ?face:String;
    var ?fontSize:Int;
    var ?sound:String;
    var ?speed:Float;
    var ?autoSkip:Bool;
    var ?formats:Array<UTTextFormat>;
}
class DialogueDefaults
{
    public static var font:String = "DeterminationMono.ttf";
    public static var size:Int = 40;
    public static var speed:Float = 0.035;
    public static var sound:String = "SND_TXT2";
    public static var face:String = "";
    public static var autoSkip:Bool = false;

    //checks for any null values and sets defaults
    public static function checkDialogueData(data:DialogueData)
    {
        if (data.font == null)
            data.font = font;
        if (data.fontSize == null)
            data.fontSize = size;
        if (data.speed == null)
            data.speed = speed;
        if (data.sound == null)
            data.sound = sound;
        if (data.face == null)
            data.face = face;
        if (data.autoSkip == null)
            data.autoSkip = autoSkip;
        return data;
    }
}

class DialogueManager
{
    var currentDialogue:Array<DialogueData> = [];
    var currentTextToDisplay:String = "";

    public var currentText:String = "";

    public var font:String = "";
    public var size:Int = 40;
    public var speed:Float = 0.035;
    public var sound:FlxSound = null;
    public var currentSoundName:String = "";
    public var face:String = "";
    public var autoSkip:Bool = false;

    var display:BaseDialogueDisplay;
    public function new(display:BaseDialogueDisplay)
    {
        this.display = display;
    }

    public function startNext()
    {
        currentText = "";
        if (currentDialogue.length > 0)
        {
            currentTextToDisplay = currentDialogue[0].text;
            //update things
            currentDialogue[0] = DialogueDefaults.checkDialogueData(currentDialogue[0]);
            if (font != currentDialogue[0].font)
            {
                font = currentDialogue[0].font;
                display.setFont(font);
            }
            speed = currentDialogue[0].speed;
            if (face != currentDialogue[0].face)
            {
                face = currentDialogue[0].face;
                display.setFace(face);
            }
            if (currentSoundName != currentDialogue[0].sound)
            {
                currentSoundName = currentDialogue[0].sound;
                setSound(currentSoundName);
            }
            display.text.size = currentDialogue[0].fontSize;
            autoSkip = currentDialogue[0].autoSkip;

            if (currentDialogue[0].formats != null)
                display.text.setTextFormats(currentDialogue[0].formats);
            else 
                display.text.setTextFormats([]);
                
            currentDialogue.remove(currentDialogue[0]);
        }
    }

    var elapsedTime:Float = 0;
    public function update(elapsed:Float)
    {
        if (currentTextToDisplay.length > 0)
        {
            elapsedTime += elapsed;
            if (elapsedTime > speed) //update text
            {
                elapsedTime -= speed;
                var doPlaySound:Bool = true;
                currentText += currentTextToDisplay.charAt(0); //add to text
                var isSpace = currentTextToDisplay.charAt(0) == " ";
                if (isSpace || currentTextToDisplay.charAt(0) == '#')
                    doPlaySound = false;

                currentTextToDisplay = currentTextToDisplay.substring(1); //remove first letter
                if (sound != null && doPlaySound)
                    sound.play(true);
            }
        }
        else
        {
            if (autoSkip && currentDialogue.length >= 1)
                startNext();
        }
    }

    public function skip()
    {
        if (currentTextToDisplay.length > 0)
        {
            currentText += currentTextToDisplay;
            currentTextToDisplay = "";
        }
    }
    public function clear()
    {
        currentTextToDisplay = "";
        currentDialogue = [];
        display.text.text = "";
        display.face.visible = false;
    }

    public function setDialogue(d:Array<DialogueData>)
    {
        currentTextToDisplay = "";
        currentDialogue = d;
    }
    public function setSound(name:String)
    {
        if (sound == null)
            sound = new FlxSound();
        sound.loadEmbedded(Paths.sound(name));
    }
    public function setFace(f:String)
    {
        face = f;
        display.setFace(face);
    }


    public var finishedDialogue(get, null):Bool;
    public var finishedLine(get, null):Bool;

	function get_finishedDialogue():Bool 
    {
		return currentDialogue.length == 0 && currentTextToDisplay.length == 0;
	}

	function get_finishedLine():Bool {
		return currentTextToDisplay.length == 0;
	}
}

class BaseDialogueDisplay extends FlxSpriteGroup
{
    public var manager:DialogueManager;
    public var text:UTTypedText;
    public var face:DialogueFace;
    override public function new()
    {
        super();
        manager = new DialogueManager(this);
        text = new UTTypedText(0,0,0,"",40);
        text.antialiasing = false;
        face = new DialogueFace();
    }

    override public function update(elapsed:Float)
    {
        manager.update(elapsed);
        text.updateShake(elapsed);
        face.update(elapsed);

        if (text.text != manager.currentText)
            text.text = manager.currentText;

        if (face.visible && !manager.finishedDialogue) //update face anim
        {
            //if (!manager.finishedLine)
            //    face.animation.paused = false;
            //else
            //    face.animation.paused = true;
        }
    }

    public function setDialogue(d:Array<DialogueData>)
    {
        text.text = "";
        setFace("");
        manager.setDialogue(d);
    }
    public function setFont(font:String)
    {
        text.font = Paths.font(font);
        manager.font = font;
    }
    public function setFace(face:String)
    {
        manager.face = face;
    }
}

class BoxDialogueDisplay extends BaseDialogueDisplay
{
    var boxW:Int = 850;
    var boxH:Int = 200;
    var edgeWidth:Int = 8;
    var gap:Int = 32;
    override public function new()
    {
        super();

        var box = new UndertaleBox(boxW, boxH);
        add(box);


        add(face);

        text.x = gap;
        text.y = gap;
        text.fieldWidth = boxW-(gap*2);
        add(text);
    }

    override public function setFace(name:String)
    {
        super.setFace(name);

        face.loadFace(name);

        //update text pos and add sprite
        if (!face.visible) //no face
        {
            text.x = x + gap;
            text.y = y + gap;
            text.fieldWidth = boxW-(gap*2);
        }
        else //there is a face
        {
            text.x = x + gap+150;
            text.y = y + gap;
            text.fieldWidth = boxW-(gap*2)-150;
            face.x = x+50;
            face.y = y+25;
        }
    }
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        if (face != null)
        {
            if (face.visible)
            {
                if (!manager.finishedDialogue)
                {
                    if (manager.finishedLine)
                    {
                        face.animation.play(manager.face, true);
                        face.animation.pause();
                    }
                    else 
                    {
                        face.animation.play(manager.face);
                    }
                }
                else 
                {
                    face.animation.play(manager.face, true);
                    face.animation.pause();
                }
            }
        }
    }
}

class DialogueFace extends FlxSprite
{
    override public function new()
    {
        super();
        visible = false;
    }
    public function loadFace(name:String)
    {
        if (name != "")
        {
            frames = Paths.getSparrowAtlas("faces/"+name);
        }
        else
        {
            visible = false;
            return;
        }

        visible = true;

        //animation.add("idle", [0], 0, false);
        animation.addByPrefix(name, name, 8, true);
        animation.play(name, true);
        antialiasing = false;

        scale.set(3,3);
        updateHitbox();

        if (Paths.fileExists("images/faces/"+name+".txt", TEXT))
        {
            var txt = Paths.getTextFromFile("images/faces/"+name+".txt");
            var shit = txt.split(",");
            trace(shit);
            offset.x -= Std.parseFloat(shit[0].trim());
            offset.y -= Std.parseFloat(shit[1].trim());
        }
    }
}

class BubbleDialogueDisplay extends BaseDialogueDisplay
{
    var leftGap:Int = 54;
    var vGap:Int = 10;
    public var character:BattleNPC;
    override public function new()
    {
        super();

        var bg = new FlxSprite().loadGraphic(Paths.image("ut/dialogueBox"));
        bg.scale.set(1.5,1.5);
        bg.updateHitbox();
        add(bg);

        text.x = leftGap;
        text.y = vGap;
        text.fieldWidth = bg.width-(leftGap+vGap);
        add(text);
        text.color = 0xFF000000;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        if (character != null)
        {
            if (character.sprite.animation.getByName(manager.face) != null)
            {
                if (!manager.finishedDialogue)
                {
                    if (manager.finishedLine)
                    {
                        character.sprite.animation.play(manager.face, true);
                        character.sprite.animation.pause();
                    }
                    else 
                    {
                        character.sprite.animation.play(manager.face);
                    }
                }
                else 
                {
                    if (character.sprite.animation.curAnim.name == manager.face)
                    {
                        character.sprite.animation.play(manager.face, true);
                        character.sprite.animation.pause();
                    }
                }
            }
        }
    }
}