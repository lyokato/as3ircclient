package org.coderepos.net.irc.loggers
{
    import org.coderepos.net.irc.IRCChannel;
    import org.coderepos.net.irc.IRCPrivateTalk;
    import org.coderepos.net.irc.IRCServer;

    public interface IChatLoggerFactory
    {
        function createChannel(channelName:String):IRCChannel;
        function createPrivateTalk(sender:String):IRCPrivateTalk;
        function createServerLogger(host:String, port:uint):IRCServer;
    }
}

