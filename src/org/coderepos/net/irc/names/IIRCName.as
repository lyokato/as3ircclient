package org.coderepos.net.irc.names
{
    public interface IIRCName
    {
        function get nick():String;
        function set nick(newNick:String):void;
        function get type():String;
        function toString():String;
        function toPrefix():String;
    }
}

