package 
{
    import org.coderepos.net.irc.IRCServer;
    import org.coderepos.net.irc.IRCMessage;

    public class DemoServerLogger extends IRCServer
    {
        private var _view:DemoIRC;

        public function DemoServerLogger(host:String, port:uint, view:DemoIRC)
        {
            super(host, port);
            _view = view;
        }

        override public function receivedMessage(m:IRCMessage):void 
        {
            _view.logLine(m.valueOf());
        }
    }
}
