package undertale.overworld;

import flixel.FlxG;
import flixel.FlxSprite;

class InteractableSprite extends FlxSprite
{
    var player:OverworldCharacter;
    public var onInteract:Void->Void;
    public var onOverlap:Void->Void;
    override public function new(X:Float, Y:Float, player:OverworldCharacter)
    {
        super(X,Y);
        this.player = player;
    }

    var triggedOverlap:Bool = false;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (player != null)
        {
            if (player.interactHitbox.overlaps(this))
            {
                if (PlayerControls.INTERACT_P)
                {
                    if (onInteract != null)
                        onInteract();
                }
                if (!triggedOverlap)
                {
                    triggedOverlap = true;
                    if (onOverlap != null)
                        onOverlap();
                }
            }

        }
    }
}