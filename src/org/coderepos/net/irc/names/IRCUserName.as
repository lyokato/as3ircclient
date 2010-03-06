package org.coderepos.net.irc.names
{
    public class IRCUserName implements IIRCName
    {

        private var _user:String;
        private var _nick:String;
        private var _host:String;

        public function IRCUserName(nick:String, user:String=null, host:String=null)
        {
            _nick = nick;
            _user = user;
            _host = host;
        }

        public function get type():String
        {
            return IRCNameType.USER;
        }

        public function get nick():String
        {
            return _nick;
        }

        public function set nick(newNick:String):void
        {
            _nick = newNick;
        }

        public function get user():String
        {
            return _user;
        }

        public function get host():String
        {
            return _host;
        }

        public function toString():String
        {
            var str:String = _nick;
            if (_user != null)
                str += "!" + _user;
            if (_host != null)
                str += "@" + _host;
            return str;
        }

        public function toPrefix():String
        {
            return ":" + toString();
        }
    }
}

