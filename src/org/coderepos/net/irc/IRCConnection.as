package org.coderepos.net.irc
{
    import flash.net.Socket;
    import flash.events.Event;
    import flash.events.ErrorEvent;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.ProgressEvent;
    import flash.utils.ByteArray;

    import org.coderepos.net.irc.events.IRCEvent;
    import org.coderepos.net.irc.names.IIRCName;

    public class IRCConnection extends EventDispatcher
    {
        private var _socket:Socket;
        private var _buffer:String;

        public function IRCConnection()
        {
            _buffer = "";
        }

        public function get connected():Boolean
        {
            return (_socket != null && _socket.connected);
        }

        public function connect(host:String, port:uint=6667, overTLS:Boolean=false):void
        {
            if (connected)
                throw new Error("Already connected");

            _socket = createSocket();
            _socket.connect(host, port);
        }

        public function disconnect():void
        {
            if (_socket != null && _socket.connected)
                _socket.close();
            dispose();
        }

        private function dispose():void
        {
            releaseSocket();
            _buffer = "";
        }

        private function releaseSocket():void
        {
            _socket.removeEventListener(Event.CONNECT, dispatchEvent);
            _socket.removeEventListener(Event.CLOSE, closeHandler);
            _socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
            _socket = null;
        }

        public function send(msg:IRCMessage):void
        {
            if (!(_socket && _socket.connected))
                throw new Error("Socket is not connected");

            trace(msg.valueOf());
            _socket.writeBytes(msg.toByteArray());
            _socket.flush();
        }

        private function createSocket():Socket
        {
            var s:Socket = new Socket();
            s.addEventListener(Event.CONNECT, dispatchEvent);
            s.addEventListener(Event.CLOSE, closeHandler);
            s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            s.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            s.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
            return s;
        }

        private function closeHandler(e:Event):void
        {
            dispose();
            dispatchEvent(e);
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            disconnect();
            dispatchEvent(e);
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            disconnect();
            dispatchEvent(e);
        }

        public function sendMessage(command:String, params:Array,
            trailing:String=null, prefix:IIRCName=null):void
        {
            send(new IRCMessage(command, params, trailing, prefix));
        }

        private function socketDataHandler(e:ProgressEvent):void
        {
            while (_socket != null && _socket.bytesAvailable) {
                var bytes:ByteArray = new ByteArray();
                _socket.readBytes(bytes, 0, _socket.bytesAvailable);
                bytes.position = 0;
                _buffer += bytes.readUTFBytes(bytes.bytesAvailable);
            }
            var eol:int;
            var line:String;
            var msg:IRCMessage;
            while (true) {
                eol = _buffer.indexOf("\r\n");
                if (eol == -1)
                    break;
                line = _buffer.substring(0, eol);
                _buffer = _buffer.substring(eol + 2);
                msg = IRCMessageParser.parse(line);
                if (msg != null)
                    dispatchEvent(new IRCEvent(IRCEvent.RECEIVED, msg));
            }
        }
    }
}

