package org.coderepos.net.irc.loggers
{
    import org.coderepos.net.irc.IRCMessage;

    public interface IServerLogger
    {
        function receivedMessage(m:IRCMessage):void;
    }
}

