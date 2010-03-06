package
{
    import org.coderepos.net.irc.IRCMessage;
    import org.coderepos.net.irc.IRCChannel;

    public class DemoChannelLogger extends IRCChannel
    {
        private static var _idCounter:uint = 0;

        public static function genID():uint
        {
            return ++_idCounter;
        }

        private var _view:DemoIRC;
        private var _conversation:DemoConversation;
        private var _memberView:DemoMemberList;

        public function DemoChannelLogger(chName:String, view:DemoIRC)
        {
            super(chName);
            _view = view;

            var id:uint = genID();

            var conversation:DemoConversation = new DemoConversation();
            var members:DemoMemberList = new DemoMemberList();

            var cid:String = "conversation_" + String(id);
            _view.conversationViewStack.addChild(conversation);
            _view.memberViewStack.addChild(members);

            _conversation = conversation;
            _memberView   = members;
            conversation.channelName = chName;
            setAttribute("conversation", _conversation);
            setAttribute("members", _memberView);

            // var membersView:DemoMembersView = new DemoMembersView();
            //_view.membersViewStack.addChild();
        }

        override public function updatedMembers():void
        {
            _memberView.list.dataProvider = memberNicks;
        }

        override public function receivedPRIVMSG(nick:String, message:String):void
        {
            // new Date();
            _conversation.chat.text += "[" + nick + "] " + message
            _conversation.chat.text += "\n";
        }

        override public function receivedNOTICE(nick:String, message:String):void
        {
            // new Date();
            // _logView.text += message
            _conversation.chat.text += "[" + nick + "] " + message
            _conversation.chat.text += "\n";
        }

        override public function receivedMessage(m:IRCMessage):void
        {
            _view.logLine(m.valueOf());
        }

        override public function sendPRIVMSG(nick:String, message:String):void
        {
            _conversation.chat.text += "[" + nick + "] " + message
            _conversation.chat.text += "\n";
        }

        override public function sendNOTICE(nick:String, message:String):void
        {
            _conversation.chat.text += "[" + nick + "] " + message
            _conversation.chat.text += "\n";
        }
    }
}

