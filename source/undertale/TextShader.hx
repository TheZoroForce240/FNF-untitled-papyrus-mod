package undertale;

import flixel.system.FlxAssets.FlxShader;

//fix for blurry text
class TextShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        void main()
        {
            vec4 spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);
            if (spritecolor.a > 0.0 && spritecolor.a < 1.0)
            {
                float inverseAlpha = 1.0 / spritecolor.a;
                spritecolor.rgb *= inverseAlpha;
                spritecolor.a = 1.0;
            }
            gl_FragColor = spritecolor;
        }
    ')
    override public function new()
    {
        super();
    }
}