package org.coderepos.net.irc
{
    public class IRCUser
    {
        public var name:IRCUserName;
        public var isInvisible:Boolean;
        public var isServerOperator:Boolean;
        public var isLocalServerOperator:Boolean;
        public var isAway:Boolean;
        public var isRistricted:Boolean;
        public var acceptsServerNotice:Boolean;
        public var acceptsWallops:Boolean;

        public function IRCUser(name:IRCUserName=null)
        {
            name = name;
            isInvisible           = false;
            isServerOperator      = false;
            isLocalServerOperator = false;
            isAway                = false;
            isRistricted          = false;
            acceptsServerNotice   = false;
            acceptsWallops        = false;
        }

        public function get nick():String
        {
            if (name == null)
                return null;
            return name.nick;
        }

        public function get user():String
        {
            if (name == null)
                return null;
            return name.user;
        }

        public function get host():String
        {
            if (name == null)
                return null;
            return name.host;
        }

        public function toString():String
        {
            if (name == null)
                return null;
            return name.toString();
        }

        public function toPrefix():String
        {
            if (name == null)
                return null;
            return ":" + toString();
        }

    }
}
