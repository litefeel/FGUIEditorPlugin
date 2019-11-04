/*******************************************
 * Author : hanxianming
 * Date   : 2016-3-23
 * Use    :
 *******************************************/

package
{
	import com.litefeel.utils.FileUtil;
	import flash.filesystem.File;
	
	import fairygui.editor.plugin.ICallback;
	import fairygui.editor.plugin.IFairyGUIEditor;
	import fairygui.editor.plugin.IPublishData;
	import fairygui.editor.plugin.IPublishHandler;
	import flash.utils.*;
	
	public final class AutoGenerateCodePluginTest implements IPublishHandler
	{
		
		private var packageObjByGid:Object = {};
		private var packageObjByClassName:Object = {};
		
		private var _editor:IFairyGUIEditor;
		
		private var _prefix:String = "UI_";
		private var _memberNamePrefix:String = "m_";
		private var _globalCodePath:String;
		
		
		public function AutoGenerateCodePluginTest(editor:IFairyGUIEditor)
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
			if (_editor.project.type != "Unity")
			{
				//_editor.alert("project type is " + _editor.project.type);
				return false;
			}
			
			setTimeout(_doExport, 0.1, data);
			return false;
			//setTimeout(_doExport()
			//{
				//var path = "E:/GitHub/Unity/FGUI/Assets/UI/Scripts/Package1/UI_Component1.cs";
				//FileUtil.writeString("ddddddd", path);
			//}, 0.1);
		}
		
		private function _doExport(data:IPublishData):void 
		{
			var packageXML:XML = new XML(FileUtil.readString(joinPath(data.targetUIPackage.basePath, "package.xml")));

			if (packageXML.publish.@genCode != "true")
			{
				return;
			}
			var packageId:String = data.targetUIPackage.id;
			var packageName:String = data.targetUIPackage.name;
			
			
			var classCodes:Array = [];
			var bindCodes:Array = [];
			var allBindCodes:Array = [];
			var sameNameCheck:Object;
			
			
			var publishObj:Object = JSON.parse(FileUtil.readString(joinPath(_editor.project.basePath, "settings", "Publish.json")));
			_prefix = publishObj.codeGeneration.classNamePrefix;
			_globalCodePath = publishObj.codeGeneration.codePath;
			_memberNamePrefix = "";// publishObj.codeGeneration.memberNamePrefix;
			
			var codeDir:String = joinPath(_globalCodePath, packageName);
			if (codeDir.charAt(0) == ".")
				codeDir = joinPath(_editor.project.basePath, codeDir);
				
			
			for each (var classInfo:Object in data.outputClasses)
			{
				classCodes.length = 0;
				
				var className:String = _prefix + PinYinUtils.toPinyin(classInfo.className); //你也可以加个前缀后缀啥的
				
				
				classCodes.push("/** This is an automatically generated class by FairyGUI. Please do not modify it. **/");
				classCodes.push("")
				classCodes.push("using FairyGUI;")
				classCodes.push("using FairyGUI.Utils;")
				classCodes.push("")
				classCodes.push("namespace " + packageName);
				classCodes.push("{");
				classCodes.push("\tpublic partial class " + className + " : " + (classInfo.customSuperClassName ? classInfo.customSuperClassName : classInfo.superClassName));
				classCodes.push("\t{");
				
				for each (var memberInfo:Object in classInfo.members) 
				{
					classCodes.push("\t\tpublic " + getMemberTypeName(memberInfo) + " " +_memberNamePrefix + memberInfo.name + ";");
				}
				
				classCodes.push("");
				classCodes.push("\t\tpublic const string URL = " + "\"ui://" + data.targetUIPackage.id + classInfo.classId + "\";");
				classCodes.push("");
				
				classCodes.push("\t\tpublic static " + className + " CreateInstance()");
				classCodes.push("\t\t{");
				classCodes.push("\t\t\treturn (" + className+')UIPackage.CreateObject("' + packageName + '","' + PinYinUtils.toPinyin(classInfo.className) +'");');
				classCodes.push("\t\t}");
				classCodes.push("");
				
				// 构造函数
				classCodes.push("\t\tpublic " + className + "()");
				classCodes.push("\t\t{");
				classCodes.push("\t\t}");
				classCodes.push("");
				
				// ConstructFromXML
				classCodes.push("\t\tpublic override void ConstructFromXML(XML xml)");
				classCodes.push("\t\t{");
				classCodes.push("\t\t\tbase.ConstructFromXML(xml);");
				classCodes.push("");
				
				var childIndex:int = 0;
				var controllerIndex:int = 0;
				var transitionIndex:int = 0;
				for each (var memberInfo:Object in classInfo.members)
				{
					
					var getPrefix:String = "\t\t\t" + _memberNamePrefix + memberInfo.name+" = ";
					if (memberInfo.type == "Controller")
					{
						classCodes.push(getPrefix + "this.GetControllerAt(" + controllerIndex + ");");
						controllerIndex++;
					}
					else if (memberInfo.type == "Transition")
					{
						classCodes.push(getPrefix + "this.GetTransitionAt(" + transitionIndex + ");");
						transitionIndex++;
					}
					else
					{
						classCodes.push(getPrefix + "(" + getMemberTypeName(memberInfo) + ")this.GetChildAt(" + childIndex + ");");
						childIndex++;
					}
				}
				classCodes.push("\t\t}");
				classCodes.push("\t}");
				classCodes.push("}");
				
				//_editor.alert("eeeeeeeeeeeee " + joinPath(codeDir, className+".cs"));
				
				FileUtil.writeString(classCodes.join("\n"), joinPath(codeDir, className+".cs"));
				
				//				bindCodes.push("\t\t\tUIObjectFactory.setPackageItemExtension(\"ui://" + data.targetUIPackage.id + classInfo.classId
				//					+ "\"," + className + ");");
				
				//bindCodes.push("\t\t\tUIObjectFactory.setPackageItemExtension(" + className + ".url, " + className + ");");
				
			}
			_editor.alert("Publish Success");

		}
		
		private function getMemberTypeName(member:Object):String 
		{
			if (member.pkg) return member.pkg + "." + _prefix + member.src;
			if (member.src) return _prefix + member.src;
			return member.type;
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
		
		private function joinPath(...path):String 
		{
			return path.join(File.separator);
		}
	}

}