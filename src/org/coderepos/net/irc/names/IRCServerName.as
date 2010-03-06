package org.coderepos.net.irc.names
{
    public class IRCServerName implements IIRCName
    {
        private var _name:String;

        public function IRCServerName(name:String)
        {
            _name = name;
        }

        public function get type():String
        {
            return IRCNameType.SERVER;
        }

        public function get nick():String
        {
            return _name;
        }

        public function set nick(newNick:String):void
        {
        }

        public function toString():String
        {
            return _name;
        }

        public function toPrefix():String
        {
            return ":" + _name;
        }
    }
}

