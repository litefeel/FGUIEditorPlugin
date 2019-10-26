package 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author litefeel
	 */
	public class FileUtils 
	{
		
		public static function writeObj(o:Object, path:String):void 
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(o);
			FileTool.writeByte(path, bytes);
		}
		
		public static function readObj(path:String):Object 
		{
			var bytes:ByteArray = FileTool.readByte(path);
			return bytes.readObject();
		}
		
	}

}