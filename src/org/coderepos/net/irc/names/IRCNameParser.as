package org.coderepos.net.irc.names
{
    public class IRCNameParser
    {
        public static function parse(s:String):IIRCName
        {
            var result:Array;
            result = s.match(/^[&#+!][^\s\,]+&/);
            if (result != null)
                return IRCChannelName(s);
            result = s.match(/^([^!@]+)(?:(?:\!([^@]+))?(?:\@(\S+)))?$/);
            if (result != null)
                return new IRCUserName(result[1], result[2], result[3]);
            // XXX: Is this correct?
            // Is there a case that server name acts as a prefix?
            return IRCServerName(s);
        }

        public static function parseUserName(s:String):IRCUserName
        {
            var result:Array = s.match(/^([^!@]+)(?:(?:\!([^@]+))?(?:\@(\S+)))?$/);
            return (result == null)
                ? null : new IRCUserName(result[1], result[2], result[3]);
        }
    }
}

