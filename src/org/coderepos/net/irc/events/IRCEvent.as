package org.coderepos.net.irc.events
{
    import flash.events.Event;
    import org.coderepos.net.irc.IRCMessage;

    public class IRCEvent extends Event
    {
        public static const RECEIVED:String   = "received";
        public static const REGISTERED:String = "registered";
        public static const JOINED:String     = "joined";

        private var _response:IRCMessage;

        public function IRCEvent(type:String, msg:IRCMessage=null,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _response = msg;
            super(type, bubbles, cancelable);
        }

        public function get message():IRCMessage
        {
            return _response;
        }

        override public function clone():Event
        {
            return new IRCEvent(type, _response, bubbles, cancelable);
        }
    }
}
