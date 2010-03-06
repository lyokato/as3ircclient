package org.coderepos.net.irc
{
    import com.adobe.utils.StringUtil;
    import org.coderepos.net.irc.names.IIRCName;
    import org.coderepos.net.irc.names.IRCNameParser;

    public class IRCMessageParser
    {
        public static function parse(src:String):IRCMessage
        {
            src = StringUtil.trim(src);

            // if empty line
            var length:int = src.length;
            if (length == 0)
                return null;

            var commandPart:String;
            var prefix:IIRCName;
            var trailing:String;
            var params:Array;

            var hasPrefix:Boolean;

            // if found trailing
            var trailingIndex:int = src.indexOf(":", 1);
            if (trailingIndex != -1) {
                trailing = src.substring(trailingIndex + 1).replace(/(?:\r|\n)$/, "");
                src = StringUtil.trim(src.substring(0, trailingIndex));
            }

            var parts:Array = src.split(/\s+/);

            // if found prefix
            if (src.charAt(0) == ":") {
                parts = src.split(/\s+/);
                if (parts.length < 2)
                    throw new Error("Invalid Message Format");
                var prefixPart:String = parts.shift().substring(1);
                prefix = IRCNameParser.parse(prefixPart);
                if (prefix == null)
                    throw new Error("Invalid Prefix Format");
            }

            if (parts.length == 0)
                throw new Error("Command Not Found");

            var command:String = parts.shift();

            if (parts.length > 0) {
                params = parts;
            }

            return new IRCMessage(command, params, trailing, prefix);
        }
    }
}

