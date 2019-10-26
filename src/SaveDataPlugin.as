/*******************************************
 * Author : hanxianming
 * Date   : 2016-3-23
 * Use    : 
 *******************************************/

package
{
	import flash.filesystem.File;
	
	import fairygui.editor.plugin.ICallback;
	import fairygui.editor.plugin.IFairyGUIEditor;
	import fairygui.editor.plugin.IPublishData;
	import fairygui.editor.plugin.IPublishHandler;
	
	public final class SaveDataPlugin implements IPublishHandler
	{
		
		private var packageObjByGid:Object = {};
		private var packageObjByClassName:Object = {};
		
		private var _editor:IFairyGUIEditor;
		
		private var _prefix:String = "UI_";
		
		public function SaveDataPlugin(editor:IFairyGUIEditor)
		{
			_editor = editor;
		}
		
		
		/**
		 * 组件输出类定义列表。这是一个Map，key是组件id，value是一个结构体，例如：
		 * {
		 * 		classId : "8swdiu8f",
		 * 		className ： "AComponent",
		 * 		superClassName : "GButton",
		 * 		members : [
		 * 			{ name : "n1" : type : "GImage" },
		 * 			{ name : "list" : type : "GList" },
		 * 			{ name : "a1" : type : "GComponent", src : "Component1" },
		 * 			{ name : "a2" : type : "GComponent", src : "Component2", pkg : "Package2" },
		 * 		]
		 * }
		 * 注意member里的name并没有做排重处理。
		 */
		
		public function doExport(data:IPublishData, callback:ICallback):Boolean
		{
			
			FileUtils.writeObj(data, "D:/My/Projects/FGUIEditorPluginDebuger/data.bytes");
			//FileUtils.writeObj(_editor, "D:/My/Projects/FGUIEditorPluginDebuger/editor.bytes");
			data.preventDefault();
			
			
			callback.callOnSuccess();
			return true;
		}
		
		
		
		private function getFilePackage(packageStr:String):String
		{
			return packageStr.replace(new RegExp("\\.", "g"), File.separator);
		}
		
		private function getPackageName(classId:String):String
		{
			var packages:Vector.<String> = new Vector.<String>();
			var packageName:String = "";
			var folderId:String = packageObjByGid[classId].@folder;
			while (folderId != "" && folderId != null)
			{
				packages.push(packageObjByGid[folderId].@name);
				folderId = packageObjByGid[folderId].@folder;
			}
			
			if (packages.length > 0)
			{
				packages.reverse();
				packageName = packages.join("."); 
			}
			
			return packageName;
		}
		
		private function getPackageNameByClassName(className:String):String
		{
			var obj:Object = packageObjByClassName[className];
			if (obj == null)
			{
				return "";
			}
			
			var smallPackageName:String = getPackageName(obj.xml.@id);
			
			return "viewuicode." + obj.packageName + (smallPackageName == "" ? "" : ("." + smallPackageName));
		}
		
		private function checkIsUseDefaultName(name:String):Boolean
		{
			if (name.charAt(0) == "n" || name.charAt(0) == "c" || name.charAt(0) == "t")
			{
				return _isNaN(name.slice(1));
			}
			return false;
		}
		
		private function _isNaN(str:String):Boolean
		{
			if (isNaN(parseInt(str)))
			{
				return false;
			}
			return true;
		}
	}
	
	
}