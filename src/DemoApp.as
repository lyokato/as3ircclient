package 
{
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.display.NativeWindow;
    import flash.desktop.NativeApplication;

    import nl.demonsters.debugger.MonsterDebugger;

    import org.coderepos.net.irc.IRCServerSetting;
    import org.coderepos.net.irc.IRCClient;
    import org.coderepos.net.irc.names.IRCUserName;
    import org.coderepos.net.irc.events.IRCEvent;

    public class DemoApp extends EventDispatcher
    {
        private static var _app:DemoApp;

        public static function get app():DemoApp
        {
            if (_app == null)
                _app = new DemoApp();
            return _app;
        }

        private var _debugger:MonsterDebugger;
        private var _rootWindow:DemoIRC;
        private var _settingWindow:DemoSettingWindow;
        private var _setting:DemoSetting;

        private var _client:IRCClient;
        private var _factory:DemoLoggerFactory;

        public function DemoApp()
        {
            _debugger = new MonsterDebugger(this);
            _setting  = DemoSetting.load();
        }

        public function set rootWindow(win:DemoIRC):void
        {
            _rootWindow = win;
            _rootWindow.addEventListener(Event.CLOSING, shutDown);
            _factory = new DemoLoggerFactory(_rootWindow);
        }

        private function shutDown(e:Event):void
        {
            saveSettings();
            closeAllWindows();
        }

        private function saveSettings():void
        {
            _setting.save();
        }

        private function closeAllWindows():void
        {
            var openedWindows:Array =
                NativeApplication.nativeApplication.openedWindows;
            for (var i:int = openedWindows.length - 1; i >= 0; --i) {
                var win:NativeWindow = openedWindows[i] as NativeWindow;
                win.close();
            }
        }

        public function get connected():Boolean
        {
            return (_client != null && _client.connected);
        }

        public function connect():void
        {
            if (connected)
                return;

            var s:IRCServerSetting = _setting.genIRCServerSetting();
            // TODO: check if setting has enough info to connect
            _client = new IRCClient(s, _factory);
            _client.addEventListener(Event.CONNECT, connectHandler);
            _client.addEventListener(Event.CLOSE, closeHandler);
            _client.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _client.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _client.addEventListener(IRCEvent.REGISTERED, registerHandler);
            _client.addEventListener(IRCEvent.JOINED, joinedHandler);
            _client.connect();
        }

        public function addChannel(chName:String):void
        {
            if (!(chName.length > 0 && chName.charAt(0) == "#"))
                return;
            if (!connected)
                return;

            _client.join(chName);
        }

        public function sendMessage(chName:String, message:String):void
        {
            if (connected)
                _client.privmsg(chName, message);
        }

        public function get channels():Array
        {
            return connected ? _client.channels : []
        }

        public function disconnect():void
        {
            if (connected)
                _client.disconnect();
        }

        public function openSettingWindow():void
        {
            if (_settingWindow == null || _settingWindow.closed) {
                _settingWindow = new DemoSettingWindow();
                _settingWindow.open();
                _settingWindow.setting = _setting;
            }
            _settingWindow.activate();
        }

        private function joinedHandler(e:IRCEvent):void
        {
            _rootWindow.logLine("[JOINED]");
            _rootWindow.sessions.dataProvider = _client.channels;
        }

        private function registerHandler(e:IRCEvent):void
        {
            _rootWindow.logLine("[REGISTERED]");
            _rootWindow.logLine(_client.me.toString());
        }

        private function connectHandler(e:Event):void
        {
            _rootWindow.logLine("[CONNECTED]");
        }

        private function closeHandler(e:Event):void
        {
            _rootWindow.logLine("[CONNECTION CLOSED]");
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            _rootWindow.logLine("[IO ERROR]");
            _rootWindow.logLine(e.toString());
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            _rootWindow.logLine("[SECURITY ERROR]");
            _rootWindow.logLine(e.toString());
        }
    }
}

