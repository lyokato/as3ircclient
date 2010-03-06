package org.coderepos.net.irc
{
    import org.coderepos.net.irc.loggers.IServerLogger;

    public class IRCServer implements IServerLogger
    {
        protected var _host:String;
        protected var _port:uint;

        public function IRCServer(host:String, port:uint):void
        {
            _host = host;
            _port = port;
        }

        public function get host():String
        {
            return _host;
        }

        public function get port():uint
        {
            return _port;
        }

        public function receivedMessage(m:IRCMessage):void
        {

        }
    }
}

