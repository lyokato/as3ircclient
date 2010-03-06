package suite {
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.net.irc.IRCMessageParser;
    import org.coderepos.net.irc.IRCMessage;
    import org.coderepos.net.irc.IRCUserMode;
    import org.coderepos.net.irc.ReconnectionManager;
    import org.coderepos.net.irc.IRCConnection;
    import org.coderepos.net.irc.IRCCommands;
    import org.coderepos.net.irc.IRCChannel;
    import org.coderepos.net.irc.IIRCChatSession;
    import org.coderepos.net.irc.IRCServerSetting;
    import org.coderepos.net.irc.IRCUtil;
    import org.coderepos.net.irc.NumericReplies;
    import org.coderepos.net.irc.IRCClient;
    import org.coderepos.net.irc.names.IIRCName;
    import org.coderepos.net.irc.names.IRCServerName;
    import org.coderepos.net.irc.names.IRCUserName;
    import org.coderepos.net.irc.names.IRCNameParser;
    import org.coderepos.net.irc.names.IRCChannelName;
    import org.coderepos.net.irc.events.IRCEvent;

    public class LoadTest extends TestCase {
        public function LoadTest(meth:String) {
            super(meth);
        }

        public static function suite():TestSuite {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new LoadTest("testParse1"));
            return ts;
        }

        public function testParse1():void {
            var setting:IRCServerSetting = new IRCServerSetting();
            var c:IRCClient = new IRCClient(setting);
        }

    }
}
