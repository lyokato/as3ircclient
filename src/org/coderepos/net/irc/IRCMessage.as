package org.coderepos.net.irc
{
    import flash.utils.ByteArray;

    import org.coderepos.net.irc.names.IIRCName;

    public class IRCMessage
    {
        private var _command:String;
        private var _prefix:IIRCName;
        private var _params:Array;
        private var _trailing:String;

        public function IRCMessage(command:String,
            params:Array=null, trailing:String=null, prefix:IIRCName=null)
        {
            _command = command.toUpperCase();
            _prefix = prefix;

            /* check number of params here?.
               does it cost too much?

            var paramsCount:uint = params.length;
            if (trailing != null)
                paramsCount++;
            if (paramsCount > 15)
                throw new Error("over 15 commands params are found.");
            */

            // XXX: check params: not includes whitespace \n, \r, and null
            _params = (params != null) ? params : [];

            // XXX: check trailing: not includes \n, \r, and null
            _trailing = trailing;
        }

        public function isNumericReply():Boolean
        {
            return (_command.match(/^\d+$/) != null);
        }

        public function get command():String
        {
            return _command;
        }

        public function get prefix():IIRCName
        {
            return _prefix;
        }

        public function get params():Array
        {
            return _params;
        }

        public function get trailing():String
        {
            return _trailing;
        }

        public function toLine():String {
            return valueOf() + "\r\n";
        }

        public function toString():String
        {
            return valueOf();
        }

        public function valueOf():String
        {
            var msg:String = (_prefix != null) ? _prefix.toPrefix() + " " : "";
            msg += _command;
            // check params here?
            for each(var param:String in _params) {
                // if it inludes \r \n, remove them?
                msg += " ";
                msg += param;
            }
            if (_trailing != null) {
                msg += " :";
                msg += _trailing;
            }
            return msg;
        }

        public function copy():IRCMessage
        {
            return new IRCMessage(_command, _params, _trailing, _prefix);
        }

        public function toByteArray():ByteArray
        {
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(toLine());
            bytes.position = 0;
            return bytes;
        }
    }
}

