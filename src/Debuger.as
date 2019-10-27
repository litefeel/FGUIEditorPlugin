package 
{
	import com.litefeel.utils.FileUtil;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author litefeel
	 */
	public class Debuger extends Sprite
	{
		
		public function Debuger() 
		{
			var data:Object = FileUtil.readObject("D:/My/Projects/FGUIEditorPluginDebuger/data.bytes");
			trace(data);
		}
		
	}

}