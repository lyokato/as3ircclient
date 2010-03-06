package org.coderepos.net.irc.loggers
{
    import org.coderepos.net.irc.IRCMessage;

    public interface IChatLogger
    {
        function receivedPRIVMSG(sender:String, message:String):void;
        function receivedNOTICE(sender:String, message:String):void;
        function receivedMessage(m:IRCMessage):void;
        function sendPRIVMSG(me:String, message:String):void;
        function sendNOTICE(me:String, message:String):void;
    }
}

