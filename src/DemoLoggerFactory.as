package
{
    import org.coderepos.net.irc.loggers.DefaultLoggerFactory;
    import org.coderepos.net.irc.IRCChannel;
    import org.coderepos.net.irc.IRCServer;
    import org.coderepos.net.irc.IRCPrivateTalk;

    public class DemoLoggerFactory extends DefaultLoggerFactory
    {
        private var _rootView:DemoIRC;

        public function DemoLoggerFactory(rootView:DemoIRC)
        {
            _rootView = rootView;
        }

        override public function createChannel(channelName:String):IRCChannel
        {
            return new DemoChannelLogger(channelName, _rootView);
        }

        override public function createPrivateTalk(nick:String):IRCPrivateTalk
        {
            return new DemoTalkLogger(nick, _rootView);
        }

        override public function createServerLogger(host:String, port:uint):IRCServer
        {
            return new DemoServerLogger(host, port, _rootView);
        }
    }
}


