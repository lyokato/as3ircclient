package org.coderepos.net.irc.loggers
{
    import org.coderepos.net.irc.IRCChannel;
    import org.coderepos.net.irc.IRCPrivateTalk;
    import org.coderepos.net.irc.IRCServer;

    public class DefaultLoggerFactory implements IChatLoggerFactory
    {
        public function createChannel(channelName:String):IRCChannel
        {
            return new IRCChannel(channelName);
        }

        public function createPrivateTalk(senderNick:String):IRCPrivateTalk
        {
            return new IRCPrivateTalk(senderNick);
        }

        public function createServerLogger(host:String, port:uint):IRCServer
        {
            return new IRCServer(host, port);
        }
    }
}

