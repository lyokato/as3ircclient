package org.coderepos.net.irc
{
    import flash.utils.ByteArray;
    import org.coderepos.net.irc.names.IRCUserName;
    import org.coderepos.net.irc.names.IRCNameParser;

    public class IRCUtil
    {
        public static function escapeLowCTCP(str:String):String
        {
            return str = str.replace(/[\x00\r\n\x10]/g, function():String {
                var code:int = arguments[0].charCodeAt(0);
                var result:String = String.fromCharCode(0x10);
                switch (code) {
                    case 0x00:
                        result += String.fromCharCode(0x30);
                        break;
                    case 0x0a:
                        result += String.fromCharCode(0x6e);
                        break;
                    case 0x0d:
                        result += String.fromCharCode(0x72);
                        break;
                    case 0x10:
                        result += String.fromCharCode(0x10);
                        break;
                }
                return result;
            } );
        }

        public static function escapeCTCP(str:String):String
        {
            str = str.replace(/\\/g, "\\\\").replace(/[\x01]/g, "\\a");
            return String.fromCharCode(0x01) + escapeLowCTCP(str) + String.fromCharCode(0x01);
        }

        public static function unescapeLowCTCP(str:String):String
        {
            return str.replace(
                    /\x10\x30/g, String.fromCharCode(0x00)).replace(
                    /\x10\x6e/g, String.fromCharCode(0x0a)).replace(
                    /\x10\x72/g, String.fromCharCode(0x0d)).replace(
                    /\x10\x10/g, String.fromCharCode(0x10));
        }

        public static function splitAndUnescapeCTCP(str:String):Array
        {
            // if message includes CTCP commands, escape it.
            var matched:Array = str.match(/^([^\x01]+)(?:\x01([^\x01]+)\x01)?$/)
            if (matched == null)
                return [null, null];

            var message:String = matched[1];
            if (message != null)
                message = unescapeLowCTCP(message);
            var ctcpMessage:String = matched[2];
            if (ctcpMessage != null)
                ctcpMessage = unescapeCTCP(ctcpMessage);
            return [message, ctcpMessage];
        }

        public static function unescapeCTCP(str:String):String
        {
            return unescapeLowCTCP(str).replace(
                /\x5c\x61/g, String.fromCharCode(0x01)).replace(
                /\x5c\x5c/g, String.fromCharCode(0x5c));
        }

        public static function byteLength(str:String):uint
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(str);
            return b.length;
        }

        public static function validateNickName(nickName:String):Boolean
        {
            if (byteLength(nickName) > 9)
                return false;
            if (nickName == 'anonymous')
                return false;
            return true;
        }

        public static function validateModeParam(str:String):Boolean
        {
            return (str.match(/^[+-][a-zA-Z]+/) != null);
        }

        public static function validateUserName(userName:String):Boolean
        {

            return true;
        }

        public static function validateRealName(realName:String):Boolean
        {

            return true;
        }

        public static function validateHostName(hostName:String):Boolean
        {
            return true;
        }

        public static function validateChannelName(channelName:String):Boolean
        {
            if (byteLength(channelName) > 50)
                return false;
            return (channelName.match(/^[#&+!](\S+)$/) != null);
        }

        public static function parseWelcomeMessage(str:String):IRCUserName
        {
            var result:Array = str.match(/(\S+)$/);
            return (result != null)
                ? IRCNameParser.parseUserName(result[1]) : null;
        }

        /*
        public static function parseYourhostMessage(str:String):IRCServer;
        {
            var results:Array = str.match(/^Your host is ([^,]+), running version (\S+)+$/);
            if (result == null) {
                return null;
            } else {
                var serverName:IRCServerName = new IRCServerName(results[1]);
                var version:String = results[2];
                var server:IRCServer = new IRCServer(serverName, version);
                return server;
            }
        }

        public static function parseCreatedMessage(str:String):Date
        {
            var results:Array = str.match(/^This server was created (.+)$/);
            if (result == null) {
                return null;
            } else {
                return new Date(result[1]);
            }
        }
        */
    }
}

