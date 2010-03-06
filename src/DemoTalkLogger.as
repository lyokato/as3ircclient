package 
{
    import org.coderepos.net.irc.IRCMessage;
    import org.coderepos.net.irc.IRCPrivateTalk;

    public class DemoTalkLogger extends IRCPrivateTalk
    {
        private var _view:DemoIRC;

        public function DemoTalkLogger(sender:String, view:DemoIRC)
        {
            super(sender);
            _view = view;
        }

        override public function receivedPRIVMSG(sender:String, message:String):void
        {

        }

        override public function receivedNOTICE(sender:String, message:String):void
        {

        }

        override public function receivedMessage(m:IRCMessage):void
        {
            _view.logLine(m.valueOf());
        }

        override public function sendPRIVMSG(me:String, message:String):void
        {

        }

        override public function sendNOTICE(me:String, message:String):void
        {

        }
    }
}
