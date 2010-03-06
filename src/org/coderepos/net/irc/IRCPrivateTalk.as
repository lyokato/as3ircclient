package org.coderepos.net.irc
{
    import org.coderepos.net.irc.loggers.IChatLogger;

    public class IRCPrivateTalk implements IChatLogger
    {
        protected var _nick:String;
        protected var _attributes:Object;

        public function IRCPrivateTalk(nick:String)
        {
            _nick = nick;
            _attributes = {};
        }

        public function getAttribute(key:String):Object
        {
            return (key in _attributes) ? _attributes[key] : null;
        }

        public function setAttribute(key:String, value:Object):void
        {
            _attributes[key] = value;
        }

        public function get nick():String
        {
            return _nick;
        }

        public function set nick(n:String):void
        {
            _nick = n;
        }

        public function receivedPRIVMSG(sender:String, message:String):void
        {

        }

        public function receivedNOTICE(sender:String, message:String):void
        {

        }

        public function receivedMessage(m:IRCMessage):void
        {

        }

        public function sendPRIVMSG(me:String, message:String):void
        {

        }

        public function sendNOTICE(me:String, message:String):void
        {

        }

        public function toString():String
        {
            return _nick;
        }
    }
}

