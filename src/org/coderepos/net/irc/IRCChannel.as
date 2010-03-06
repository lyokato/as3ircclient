package org.coderepos.net.irc
{
    //import org.coderepos.net.irc.names.IRCUserName;
    import org.coderepos.net.irc.loggers.IChatLogger;

    public class IRCChannel implements IChatLogger
    {
        protected var _name:String;
        protected var _topic:String;

        protected var _users:Object;     // Vector.<String>
        protected var _operators:Object; // Vector.<String>

        protected var _isPrivate:Boolean;
        protected var _isSecret:Boolean;
        protected var _topicSetOnlyByOperator:Boolean;
        protected var _isInviteOnly:Boolean;
        protected var _isModerated:Boolean;
        protected var _anonymous:Boolean;
        protected var _usesKeyword:Boolean;
        protected var _isLimited:Boolean;

        protected var _attributes:Object;

        public function IRCChannel(name:String)
        {
            _name      = name;
            _topic     = "";
            _users     = {};
            _operators = {};

            _attributes = {};

            // status for MODE
            _isPrivate              = false;
            _isSecret               = false;
            _topicSetOnlyByOperator = false;
            _isInviteOnly           = false;
            _isModerated            = false;
            _anonymous              = false;
            _usesKeyword            = false;
            _isLimited              = false;
        }

        public function getAttribute(key:String):Object
        {
            return (key in _attributes) ? _attributes[key] : null;
        }

        public function setAttribute(key:String, value:Object):void
        {
            _attributes[key] = value;
        }

        public function get isPrivate():Boolean
        {
            return _isPrivate;
        }

        public function get isSecret():Boolean
        {
            return _isSecret;
        }

        public function get topicSetOnlyByOperator():Boolean
        {
            return _topicSetOnlyByOperator;
        }

        public function get isInviteOnly():Boolean
        {
            return _isInviteOnly;
        }

        public function get isModerated():Boolean
        {
            return _isModerated;
        }

        public function get anonymous():Boolean
        {
            return _anonymous;
        }

        public function get usesKeyword():Boolean
        {
            return _usesKeyword;
        }

        public function get isLimited():Boolean
        {
            return _isLimited;
        }

        public function get name():String
        {
            return _name;
        }

        public function get topic():String
        {
            return _topic;
        }

        public function set topic(newTopic:String):void
        {
            if (newTopic != null)
                _topic = newTopic;
        }

        public function clearMembers():void
        {
            _users     = {};
            _operators = {};
        }

        public function updatedMembers():void
        {

        }

        public function changedNick(oldNick:String, newNick:String):void
        {
            trace("changedNick from " + oldNick + " to " + newNick);
            changeUserNick(oldNick, newNick);
            changeOperatorNick(oldNick, newNick);
            updatedMembers();
        }

        public function leaved(nick:String):void
        {
            delete _users[nick];
            delete _operators[nick];
        }

        public function changeUserNick(oldNick:String, newNick:String):void
        {
            if (oldNick in _users) {
                var user:String = _users[oldNick];
                delete _users[oldNick];
                _users[newNick] = newNick;
            }
        }

        public function changeOperatorNick(oldNick:String, newNick:String):void
        {
            if (oldNick in _operators) {
                var user:String = _operators[oldNick];
                delete _operators[oldNick];
                _operators[newNick] = newNick;
            }
        }

        public function changedMode(modeSrc:String, params:Array):void
        {
            var opType:String = modeSrc.charAt(0);
            var opStr:String = modeSrc.substring(1);
            var flag:Boolean = (opStr == "+");
            while (opStr.length > 0) {
                var opCode:String = opStr.charAt(1);
                switch (opCode) {
                    case "a":
                        _anonymous = flag;
                        break;
                    case "b":
                        break;
                    case "e":
                        break;
                    case "i":
                        _isInviteOnly = flag;
                        break;
                    case "I":
                        break;
                    case "k":
                        _usesKeyword = flag;
                        break;
                    case "l":
                        _isLimited = flag;
                        break;
                    case "m":
                        _isModerated = flag;
                        break;
                    case "n":
                        break;
                    case "o":
                    case "O":
                        if (flag) {
                            for each(var o:String in params)
                                changeMemberToOperator(o);
                        } else {
                            for each(var u:String in params)
                                changeMemberToUser(u);
                        }
                        break;
                    case "p":
                        _isPrivate = flag;
                        break;
                    case "q":
                        break;
                    case "r":
                        break;
                    case "s":
                        _isSecret = flag;
                        break;
                    case "t":
                        _topicSetOnlyByOperator = flag;
                        break;
                    case "v":
                        break;
                }
                opStr = opStr.substring(1);
            }
        }

        public function changeMemberToUser(nick:String):void
        {
            var user:String = _operators[nick];
            if (user != null) {
                _users[nick] = user;
                delete _operators[nick];
            }
        }

        public function changeMemberToOperator(nick:String):void
        {
            var user:String = _users[nick];
            if (user != null) {
                _operators[nick] = user;
                delete _users[nick];
            }
        }

        public function addUser(user:String):void
        {
            delete _operators[user];
            _users[user] = user;
        }

        public function addOperator(user:String):void
        {
            delete _users[user];
            _operators[user] = user;
        }

        public function get userNicks():Array
        {
            var users:Array = [];
            for (var userNick:String in _users)
                users.push(userNick);
            return users;
        }

        public function get operatorNicks():Array
        {
            var users:Array = [];
            for (var opNick:String in _operators)
                users.push(opNick);
            return users;
        }

        public function get memberNicks():Array
        {
            var users:Array = [];
            for (var opNick:String in _operators)
                users.push(opNick);
            for (var userNick:String in _users)
                users.push(userNick);
            return users;
        }

        public function receivedPRIVMSG(sender:String, message:String):void
        {

        }

        public function receivedNOTICE(sender:String, message:String):void
        {

        }

        public function receivedMessage(m:IRCMessage):void
        {

        }

        public function sendPRIVMSG(me:String, message:String):void
        {

        }

        public function sendNOTICE(me:String, message:String):void
        {

        }

        public function toString():String
        {
            return _name;
        }
    }
}

