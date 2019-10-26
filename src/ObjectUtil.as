package 
{
	
	import flash.net.URLVariables;
	import flash.utils.*;
	/**
	 * ...
	 * @author litefeel
	 */
	public class ObjectUtil 
	{
		
		
		public static function toString(o:Object):String 
		{
			if (o == null) return "null";
			if (o is String) return String(o);
			if (o is Number) return (o as Number).toString();
			
			var urlVars:URLVariables = getNameValuePairs(o);
			for each (var key:Object in o) 
			{
				urlVars[key] = o[key];
			}
			return urlVars.toString();
		}
		
		private static var typePropertiesCache:Object = {};

        public static function getPropertyNames(instance:Object):Array {
            var className:String = getQualifiedClassName(instance);
            if(typePropertiesCache[className]) {
                return typePropertiesCache[className];
            }
            var typeDef:XML = describeType(instance);
            trace(typeDef);
            var props:Array = [];
            for each(var prop:XML in typeDef.accessor.(@access == "readwrite" || @access == "readonly")) {
                props.push(prop.@name);
            }   
            return typePropertiesCache[className] = props;
        }

        public static function getNameValuePairs(instance:Object):URLVariables {
            var props:Array = getPropertyNames(instance);
            var vars:URLVariables = new URLVariables();
            for each(var prop:String in props) {
                vars[prop] = instance[prop];
            }
            return vars;
        }
		
	}

}