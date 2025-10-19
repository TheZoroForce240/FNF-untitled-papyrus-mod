package undertale;

import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.FlxStrip;
import flixel.math.FlxMatrix;
import flixel.math.FlxAngle;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
class BattleBox extends FlxSprite
{
    public var centered:Bool = true;

    public var bottomOutline:FlxStrip;
    public var topOutline:FlxStrip;
    public var leftOutline:FlxStrip;
    public var rightOutline:FlxStrip;
    private var outlines:Array<FlxStrip> = [];
    public var EDGE_WIDTH(default, set):Float = 8;

    public var boxWidth(default, set):Float = 200;
    public var boxHeight(default, set):Float = 200;
    private var dirtyUpdateBoxSize:Bool = true; //update box size when it changes

    public var attacks:FlxTypedGroup<AttackObject>;
    public var playerAttacks:FlxTypedGroup<AttackObject>;
    public var platforms:FlxTypedGroup<Platform>;

    

    public function new(wid:Float, hei:Float, centered:Bool = true, boxColor = 0xFF000000)
    {
        this.centered = centered;
        super();

        y = 370;

        //create edges
        bottomOutline = new FlxStrip();
        topOutline = new FlxStrip();
        leftOutline = new FlxStrip();
        rightOutline = new FlxStrip();
        outlines.push(bottomOutline);
        outlines.push(topOutline);
        outlines.push(leftOutline);
        outlines.push(rightOutline);
        for (outline in outlines)
        {
            outline.makeGraphic(Std.int(EDGE_WIDTH), Std.int(EDGE_WIDTH));
            for (i in 0...8)
            {
                outline.uvtData.push(0); //should only be white
                outline.vertices.push(0);
            }
            outline.indices.push(0);
            outline.indices.push(1);
            outline.indices.push(2);
            outline.indices.push(1);
            outline.indices.push(3);
            outline.indices.push(2);
        }



        boxWidth = wid;
        boxHeight = hei;

        this.makeGraphic(Std.int(wid), Std.int(hei), boxColor);
        updateBoxSize();
        if (centered)
            this.screenCenter(X);

        attacks = new FlxTypedGroup<AttackObject>();
        playerAttacks = new FlxTypedGroup<AttackObject>();
        platforms = new FlxTypedGroup<Platform>();

        //borderColor = 0xFF00FF00;
    }
    private function set_boxWidth(value:Float):Float 
    {
        dirtyUpdateBoxSize = true;
		boxWidth = value;
		return value;
	}
    private function set_boxHeight(value:Float):Float 
    {
        dirtyUpdateBoxSize = true;
		boxHeight = value;
		return value;
	}
    private function set_EDGE_WIDTH(value:Float):Float 
    {
        dirtyUpdateBoxSize = true;
        EDGE_WIDTH = value;
        return value;
    }

    public var borderColor(default, set):FlxColor = 0xFFFFFFFF;
    private function set_borderColor(value:FlxColor):FlxColor
    {
        for (i in outlines)
            i.color = value;
        return borderColor = value;
    }
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
    override public function draw()
    {
        attacks.cameras = cameras; //make sure it matches
        playerAttacks.cameras = cameras;
        platforms.cameras = cameras;

        if (dirtyUpdateBoxSize)
            updateBoxSize();
        if (centered)
            this.screenCenter(X);
        super.draw();
        updateBoxPosition();
        bottomOutline.cameras = cameras;
        bottomOutline.draw();
        topOutline.cameras = cameras;
        topOutline.draw();

        leftOutline.cameras = cameras;
        leftOutline.draw();
        rightOutline.cameras = cameras;
        rightOutline.draw();

            
    }
    //resizes all the edges on the box
    public function updateBoxSize()
    {
        setGraphicSize(Std.int(boxWidth), Std.int(boxHeight));
        updateHitbox();

        //update sizes

        //updateEdgeOrigin();

        dirtyUpdateBoxSize = false;
    }
    public function updateBoxPosition()
    {
        //var mat:FlxMatrix = new FlxMatrix();

        /*for (i in 0...edges.length) 
        {
            var edge = edges[i];
            var xShit = [0.5, -0.5, 0, 0];
            var yShit = [0, 0, 0.5, -0.5];
            //edge.x = x+(width*xShit[i])-(edge.width*0.5) + (Math.sin(angle * FlxAngle.TO_RAD)*(width*xShit[i])); 
            //edge.y = y+(height*yShit[i])-(edge.height*0.5) + (Math.cos(angle * FlxAngle.TO_RAD)*(height*yShit[i]));

            edge.x = x;
            edge.y = y;
            edge.angle = angle; 
            edge.alpha = alpha;
        } //set xy angle

        rightEdge.x = x+width-EDGE_WIDTH; //move to the other side
        bottomEdge.y = y+height-EDGE_WIDTH; //move to the bottom
        for (i in 0...edges.length) 
        {
            var edge = edges[i];
            var mat:FlxMatrix = new FlxMatrix();
            mat.translate(-(x+width*0.5), -(y+height*0.5));
            mat.rotate(angle*FlxAngle.TO_RAD);
            mat.translate((x+width*0.5)+(edge.x+(edge.width*0.5)), (y+height*0.5)+(edge.y+(edge.height*0.5)));
            edge.x = mat.tx;
            edge.y = mat.ty;
        }*/

        var halfX = (width*0.5);
        var halfY = (height*0.5);
        var centerX = x+halfX;
        var centerY = y+halfY;
        var sin = Math.sin(angle*FlxAngle.TO_RAD);
        var cos = Math.cos(angle*FlxAngle.TO_RAD);


        //https://stackoverflow.com/questions/41898990/find-corners-of-a-rotated-rectangle-given-its-center-point-and-rotation
        var topRightX = centerX + halfX * cos - halfY * sin;
        var topRightY = centerY + halfX * sin + halfY * cos;

        var topLeftX = centerX - halfX * cos - halfY * sin;
        var topLeftY = centerY - halfX * sin + halfY * cos;

        var bottomLeftX = centerX - halfX * cos + halfY * sin;
        var bottomLeftY = centerY - halfX * sin - halfY * cos;
        

        var bottomRightX = centerX + halfX * cos + halfY * sin;
        var bottomRightY = centerY + halfX * sin - halfY * cos;

        var sinWid = EDGE_WIDTH*sin;
        var cosWid = EDGE_WIDTH*cos;

        //sorry for this code but its the only thing that worked lol
        bottomOutline.alpha = alpha;
        bottomOutline.vertices = new DrawData();
        bottomOutline.vertices.push(topLeftX-cosWid);
        bottomOutline.vertices.push(topLeftY);
        bottomOutline.vertices.push(topLeftX-sinWid-cosWid);
        bottomOutline.vertices.push(topLeftY+cosWid);
        bottomOutline.vertices.push(topRightX);
        bottomOutline.vertices.push(topRightY);
        bottomOutline.vertices.push(topRightX-sinWid);
        bottomOutline.vertices.push(topRightY+cosWid);

        topOutline.alpha = alpha;
        topOutline.vertices = new DrawData();
        topOutline.vertices.push(bottomLeftX);
        topOutline.vertices.push(bottomLeftY);
        topOutline.vertices.push(bottomLeftX-sinWid);
        topOutline.vertices.push(bottomLeftY+cosWid);
        topOutline.vertices.push(bottomRightX);
        topOutline.vertices.push(bottomRightY);
        topOutline.vertices.push(bottomRightX-sinWid);
        topOutline.vertices.push(bottomRightY+cosWid);

        leftOutline.alpha = alpha;
        leftOutline.vertices = new DrawData();
        leftOutline.vertices.push(topLeftX);
        leftOutline.vertices.push(topLeftY);
        leftOutline.vertices.push(topLeftX-cosWid);
        leftOutline.vertices.push(topLeftY-sinWid);
        leftOutline.vertices.push(bottomLeftX);
        leftOutline.vertices.push(bottomLeftY);
        leftOutline.vertices.push(bottomLeftX-cosWid);
        leftOutline.vertices.push(bottomLeftY-sinWid);

        rightOutline.alpha = alpha;
        rightOutline.vertices = new DrawData();
        rightOutline.vertices.push(topRightX);
        rightOutline.vertices.push(topRightY);
        rightOutline.vertices.push(topRightX-cosWid);
        rightOutline.vertices.push(topRightY-sinWid);
        rightOutline.vertices.push(bottomRightX);
        rightOutline.vertices.push(bottomRightY);
        rightOutline.vertices.push(bottomRightX-cosWid);
        rightOutline.vertices.push(bottomRightY-sinWid);
    }

    override public function destroy()
    {
        if (attacks != null)
        {
            attacks.destroy();
            attacks = null;
        }
        if (playerAttacks != null)
        {
            playerAttacks.destroy();
            playerAttacks = null;
        }
        if (platforms != null)
        {
            platforms.destroy();
            platforms = null;
        }
            
        super.destroy();
    }
}