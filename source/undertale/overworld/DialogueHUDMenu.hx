package undertale.overworld;

import undertale.DialogueManager.BoxDialogueDisplay;
import undertale.DialogueManager.DialogueData;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

class DialogueHUDMenu extends OverworldHUDMenu
{

    public var dialogueBox:BoxDialogueDisplay;
    public var finished:Bool = false;
    public var onComplete:Void->Void;
    override public function new(instance:OverworldState, d:Array<DialogueData>)
    {
        super(instance);

        dialogueBox = new BoxDialogueDisplay();
        add(dialogueBox);
        dialogueBox.x = (960*0.5)-(850*0.5);
        dialogueBox.y = 720 - 220;

        dialogueBox.setDialogue(d);
        dialogueBox.manager.startNext();

    }
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (PlayerControls.INTERACT_P && dialogueBox.manager.finishedLine)
        {
            dialogueBox.manager.startNext();
        }
        else if (PlayerControls.BACK_P)
        {
            dialogueBox.manager.skip();
        }

        if (dialogueBox.manager.finishedDialogue && PlayerControls.INTERACT_P)
        {
            finished = true;
            instance.closeMenu();
            if (onComplete != null)
                onComplete();
        }
    }
}