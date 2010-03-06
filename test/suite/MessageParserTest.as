package suite {
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.net.irc.IRCMessageParser;
    import org.coderepos.net.irc.IRCMessage;
    import org.coderepos.net.irc.names.IIRCName;

    public class MessageParserTest extends TestCase {
        public function MessageParserTest(meth:String) {
            super(meth);
        }

        public static function suite():TestSuite {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new MessageParserTest("testParse1"));
            ts.addTest(new MessageParserTest("testParse2"));
            return ts;
        }

        public function testParse1():void {
            var line:String = ":irc.lazy-people.org NOTICE AUTH :*** Looking up your hostname...";
            var msg:IRCMessage;
            try {
               msg = IRCMessageParser.parse(line);
            } catch (e:Error) {
                assertEquals('error check', '', e.toString());
                return;
            }
            assertNotNull(msg);
            var prefix:IIRCName = msg.prefix;
            assertEquals('prefix is correct', 'irc.lazy-people.org', prefix.toString());
            assertEquals('command is correct', 'NOTICE', msg.command);
            assertEquals('trailing is correct', '*** Looking up your hostname...', msg.trailing);
            var params:Array = msg.params;
            //assertEquals('params length is correct', '1', params.length);
            assertEquals('first param is coorect', 'AUTH', params[0]);
        }

        public function testParse2():void {
            var line:String = "PRIVMSG #mychannel this is from as3ircclient!";
            var msg:IRCMessage;
            try {
               msg = IRCMessageParser.parse(line);
            } catch (e:Error) {
                assertEquals('', '', e.toString());
            }
            assertNull('prefix not found', msg.prefix);
            assertEquals('command should be PRIVMSG', 'PRIVMSG', msg.command);
        }
    }
}
