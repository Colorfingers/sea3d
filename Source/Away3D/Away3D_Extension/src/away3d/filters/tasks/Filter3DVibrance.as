/*
*
* Copyright (c) 2014 Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

/**
 * 
 *	@reference: https://github.com/evanw/glfx.js 
 *  @reference: https://github.com/nulldesign/nd2d/blob/master/examples/tests/effect/AGAL.as
 * 
 **/

package away3d.filters.tasks
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;

	public class Filter3DVibrance extends Filter3DTaskBase
	{
		private var _data : Vector.<Number>;
		
		public function Filter3DVibrance(vibrance:Number=1)
		{
			_data = new Vector.<Number>(4,true);
			_data[0] = vibrance;			
			_data[1] = 3.0;
			_data[2] = -vibrance * 3.0;
		}
	
		public function set vibrance(value:Number):void
		{
			_data[0] = value;
			_data[2] = -value * _data[1];
		}
		
		public function get vibrance():Number
		{
			return _data[0];
		}
				
		override protected function getFragmentCode() : String
		{
			var code:String = "";
			
			code += "tex ft0, v0, fs0 <2d,linear,clamp> \n" + //vec4 color = texture2D(texture, texCoord);
					"add ft1.x, ft0.x, ft0.y \n" + //  float average = (color.r + color.g + color.b) / 3.0;
					"add ft1.x, ft1.x, ft0.z \n" +
					"div ft1.x, ft1.x, fc0.y \n" +
					"max ft2.x, ft0.x, ft0.x \n" + // float mx = max(color.r, max(color.g, color.b));\
					"max ft2.x, ft2.x, ft0.z \n" +
					"sub ft2.y, ft2.x, ft1.x \n" + // float amt = (mx - average) * (-amount * 3.0);
					"mul ft2.z, ft2.y, fc0.z \n" +
					"sub ft3, ft2.x, ft0 \n" + // color.rgb = mix(color.rgb, vec3(mx), amt);
					"mul ft3, ft3, ft2.z \n" +
					"add ft3, ft3, ft0 \n" +
					"mov oc, ft3 \n";
			
			return code;
		}
		
		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void
		{				
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _data, 1);
		}
	}
}
