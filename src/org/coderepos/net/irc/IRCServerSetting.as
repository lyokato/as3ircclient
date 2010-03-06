package org.coderepos.net.irc
{
    public class IRCServerSetting
    {
        public var host:String;
        public var port:uint;
        public var overTLS:Boolean;
        public var password:String;
        public var username:String;
        public var usermode:String;
        public var realname:String;
        public var nickname:String;
        public var presetChannels:Array;
        public var reconnectionAcceptableInterval:uint;
        public var reconnectionMaxCountWithinInterval:uint;

        public function IRCServerSetting()
        {
            host           = "";
            username       = "";
            realname       = "";
            nickname       = "";
            password       = "";
            port           = 6667;
            overTLS        = false;
            usermode       = IRCUserMode.NUM_NORMAL;
            presetChannels = [];

            reconnectionAcceptableInterval     = 5;
            reconnectionMaxCountWithinInterval = 60 * 5;

        }
    }
}

