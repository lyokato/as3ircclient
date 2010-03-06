package org.coderepos.net.irc
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;

    import org.coderepos.net.irc.events.IRCEvent;
    import org.coderepos.net.irc.names.IRCUserName;
    import org.coderepos.net.irc.loggers.IChatLoggerFactory;
    import org.coderepos.net.irc.loggers.IChatLogger;
    import org.coderepos.net.irc.loggers.IServerLogger;

    public class IRCClient extends EventDispatcher
    {
        private var _serverSetting:IRCServerSetting;
        private var _me:IRCUserName;
        private var _names:Object;
        private var _privateTalks:Object; // Map.<String(userNickname), IRCPrivateTalk>
        private var _channels:Object;     // Map.<String(channelName), IRCChannel>
        private var _connection:IRCConnection;
        private var _isRegistered:Boolean;
        private var _registered:uint;
        private var _reconnectionManager:ReconnectionManager;
        private var _loggerFactory:IChatLoggerFactory;
        private var _serverLogger:IServerLogger;

        public function IRCClient(serverSetting:IRCServerSetting, loggerFactory:IChatLoggerFactory)
        {
            _serverSetting = serverSetting;
            _loggerFactory = loggerFactory;
            _serverLogger  =
                loggerFactory.createServerLogger(serverSetting.host, serverSetting.port);
            _channels      = {};
            _names         = {};
            _privateTalks  = {};
            _registered    = 0;
            _isRegistered  = false;
            _reconnectionManager =
                new ReconnectionManager(
                    _serverSetting.reconnectionAcceptableInterval,
                    _serverSetting.reconnectionMaxCountWithinInterval);
        }

        public function dispose():void
        {
            _channels     = {};
            _names        = {};
            _privateTalks = {};
            _registered   = 0;
            _isRegistered = false;
        }

        public function disconnect():void
        {
            if (_connection != null)
                _connection.disconnect();
            dispose();
        }

        public function get connected():Boolean
        {
            return (_connection != null && _connection.connected);
        }

        public function connect():void
        {
            _connection = new IRCConnection();
            _connection.addEventListener(Event.CONNECT, connectHandler);
            _connection.addEventListener(Event.CLOSE, closeHandler);
            _connection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _connection.addEventListener(IRCEvent.RECEIVED, receivedHandler);
            _connection.connect(_serverSetting.host, _serverSetting.port, _serverSetting.overTLS);
        }

        public function get me():IRCUserName
        {
            return _me;
        }

        public function get channels():Array // Vector.<IRCChannel>
        {
            var channels:Array = [];
            for (var channelName:String in _channels) {
                channels.push(_channels[channelName]);
            }
            return channels;
        }

        public function get privateTalks():Array // Vector.<IRCPrivateTalk>
        {
            var privateTalks:Array = [];
            for (var nick:String in _privateTalks) {
                privateTalks.push(_privateTalks[nick]);
            }
            return privateTalks;
        }

        public function join(channelName:String):void
        {
            // XXX: validate channelName
            if (channelName in _channels)
                throw new ArgumentError("Already joined the channel: " + channelName);
            _connection.sendMessage(IRCCommands.JOIN, [channelName]);
            _names[channelName] = [];
        }

        public function names(channelName:String):void
        {
            _connection.sendMessage(IRCCommands.NAMES, [channelName]);
            _names[channelName] = [];
        }

        public function canOperateChannel(channelName:String):Boolean
        {
            return (
                (channelName in _channels)
                && (_me.nick in _channels[channelName].operators)
            );
        }

        public function kick(channelName:String, nick:String,
            message:String=null):void
        {
            if (canOperateChannel(channelName))
                _connection.sendMessage(IRCCommands.KICK,
                    [channelName, nick], message);
        }

        public function ban(channelName:String, nick:String):void
        {
            if (canOperateChannel(channelName))
                _connection.sendMessage(IRCCommands.MODE,
                    [channelName, "+b", nick]);
        }

        public function kickAndBan(channelName:String, nick:String,
            message:String=null):void
        {
            if (canOperateChannel(channelName)) {
                _connection.sendMessage(IRCCommands.KICK,
                    [channelName, nick], message);
                _connection.sendMessage(IRCCommands.MODE,
                    [channelName, "+b", nick]);
            }
        }

        public function addVoice(channelName:String, nick:String):void
        {
            if (canOperateChannel(channelName))
                _connection.sendMessage(IRCCommands.MODE,
                    [channelName, "+v", nick]);
        }

        public function devoice(channelName:String, nick:String):void
        {
            if (canOperateChannel(channelName))
                _connection.sendMessage(IRCCommands.MODE,
                    [channelName, "-v", nick]);
        }

        public function canSetTopic(channelName:String):Boolean
        {
            if (!(channelName in _channels))
                return false;
            return ( (  _channels[channelName].topicSetOnlyByOperator
                && canOperateChannel(channelName) )
                    || !_channels[channelName].topicSetOnlyByOperator );
        }

        public function setTopic(channelName:String, message:String):void
        {
            if (canSetTopic(channelName))
                _connection.sendMessage(IRCCommands.TOPIC, [channelName], message);
        }

        public function getTopic(channelName:String):void
        {
            _connection.sendMessage(IRCCommands.TOPIC, [channelName]);
        }

        public function whois(usernick:String):void
        {
            _connection.sendMessage(IRCCommands.WHOIS, [usernick]);
        }

        public function canInvite(channelName:String, usernick:String):Boolean
        {
            if (!(channelName in _channels))
                return false;
            return ( (  _channels[channelName].isInviteOnly
                && canOperateChannel(channelName) )
                    || !_channels[channelName].isInviteOnly );
        }

        public function invite(channelName:String, usernick:String):void
        {
            if (canInvite(channelName, usernick))
                _connection.sendMessage(IRCCommands.INVITE,
                    [usernick, channelName]);
        }

        public function away(message:String):void
        {
            // XXX: should use 'MODE +a' instead of AWAY command?
            _connection.sendMessage(IRCCommands.AWAY, [],
                message);
        }

        public function part(channelName:String, message:String):void
        {
            _connection.sendMessage(IRCCommands.PART, [channelName],
                message);
        }

        public function privmsg(target:String, message:String):void
        {
            //XXX: validate target, fold, filter(whitespcae, \r, \n, null) and encode charset of message
            if (target.match(/^[#$!+]/) != null) {
                if (target in _channels) {
                    _channels[target].sendPRIVMSG(_me.nick, message);
                }
            } else {
                if (!(target in _privateTalks)) {
                    _privateTalks[target] =
                        _loggerFactory.createPrivateTalk(target);
                }
                _privateTalks[target].sendPRIVMSG(_me.nick, message);
            }
            _connection.sendMessage(IRCCommands.PRIVMSG, [target],
                IRCUtil.escapeLowCTCP(message));
        }

        public function notice(target:String, message:String):void
        {
            //XXX: validate target, fold, filter(whitespcae, \r, \n, null) and encode charset of message
            if (target.match(/^[#$!+]/) != null) {
                if (target in _channels) {
                    _channels[target].sendNOTICE(_me.nick, message);
                }
            } else {
                if (!(target in _privateTalks)) {
                    _privateTalks[target] =
                        _loggerFactory.createPrivateTalk(target);
                }
                _privateTalks[target].sendNOTICE(_me.nick, message);
            }
            _connection.sendMessage(IRCCommands.NOTICE, [target],
                IRCUtil.escapeLowCTCP(message));
        }

        public function quit(message:String):void
        {
            _connection.sendMessage(IRCCommands.QUIT, [], message);
        }

        private function pong():void
        {
            var nick:String = (_me != null && _me.nick != null)
                ? _me.nick : "";
            _connection.sendMessage(IRCCommands.PONG, [nick]);
        }

        private function retryNick(m:IRCMessage):void
        {
            var unavailableNick:String = m.params[m.params.length - 1]
            _connection.sendMessage(IRCCommands.NICK,
                [unavailableNick + "_"]);
        }

        private function joinedChannel(m:IRCMessage):void
        {
            var channelName:String = m.trailing;
            _channels[channelName] =
                _loggerFactory.createChannel(channelName);
            dispatchEvent(new IRCEvent(IRCEvent.JOINED));
        }

        private function rememberChannelMembers(m:IRCMessage):void
        {
            var channelName:String = m.params[m.params.length - 1];
            for each(var user:String in m.trailing.split(/\s+/))
                _names[channelName].push(user);
        }

        private function updateChannelMembers(m:IRCMessage):void
        {
            for (var channelName:String in _names) {
                if (channelName in _channels) {
                    var channel:IRCChannel = _channels[channelName];
                    channel.clearMembers();
                    for each(var user:String in _names[channelName]) {
                        if (user.charAt(0) == '@')
                            channel.addOperator(user.substring(1));
                        else
                            channel.addUser(user);
                    }
                    channel.updatedMembers();
                }
                delete _names[channelName];
            }
        }

        private function receivedPRIVMSG(m:IRCMessage):void
        {
            var target:String  = m.params[0];
            var sender:String  = m.prefix.nick;
            var message:String = m.trailing;

            trace("received PRIVMSG");
            trace("target:" + target);
            trace("sender:" + sender);

            var result:Array = IRCUtil.splitAndUnescapeCTCP(message);
            if (result[0] != null) {
                if (target.match(/^[#&!+]/) != null) { // channel
                    if (target in _channels) {
                        trace("channel found:" + target);
                        _channels[target].receivedPRIVMSG(sender, result[0]);
                    } else {
                        trace("channel not found:" + target);
                        pushToServerLog(m);
                    }
                } else if (_me != null && target == _me.nick) { // private talks
                    trace("target is me");
                    if (!(sender in _privateTalks)) {
                        _privateTalks[sender] =
                            _loggerFactory.createPrivateTalk(sender);
                    }
                    _privateTalks[sender].receivedPRIVMSG(sender, result[0]);
                } else {
                    pushToServerLog(m);
                }
            }
            if (result[1] != null) {
                // Handle CTCP Request
            }

        }

        private function receivedNOTICE(m:IRCMessage):void
        {
            var target:String  = m.params[0];
            var sender:String  = m.prefix.nick;
            var message:String = m.trailing;

            var result:Array = IRCUtil.splitAndUnescapeCTCP(message);
            if (result[0] != null) {
                if (target.match(/^[#&!+]/) != null) {
                    if (target in _channels) {
                        _channels[target].receivedNOTICE(sender, result[0]);
                    } else {
                        pushToServerLog(m);
                    }
                } else if (_me != null && target == _me.nick) {
                    if (!(sender in _privateTalks)) {
                        _privateTalks[sender] =
                            _loggerFactory.createPrivateTalk(sender);
                    }
                    _privateTalks[sender].receivedNOTICE(sender, result[0]);
                } else {
                    pushToServerLog(m);
                }
            }
            if (result[1] != null) {
                // Handle CTCP Response
            }
        }

        /*
        private function parseUserMode(modeSrc:String):IRCUserMode
        {
            var opType:String = modeSrc.charAt(0);
            var opStr:String = modeSrc.substring(1);
            var op:IRCUserMode = new IRCUserMode(opType);
            while (opStr.length > 0) {
                var opCode:String = opStr.charAt(1);
                switch (opCode) {
                    case "a":
                        op.away = true;
                        break;
                    case "i":
                        op.invisible = true;
                        break;
                    case "w":
                        op.wallop = true;
                        break;
                    case "r":
                        op.ristricted = true;
                        break;
                    case "o":
                        op.operator = true;
                        break;
                    case "O":
                        op.localOperator = true;
                        break;
                    case "s":
                        op.acceptServerNotification = true;
                        break;
                }
                opStr = opStr.substring(1);
            }
            return op;
        }
        */

        private function changedMode(m:IRCMessage):void
        {
            var target:String  = m.params[0];
            var modeSrc:String = m.params[1];
            if (target.match(/^[#$!+]/) != null) {
                if (target in _channels) {
                    m.params.shift();
                    m.params.shift();
                    _channels[target].changedMode(modeSrc, m.params);
                } else {
                    pushToServerLog(m);
                }
            } else {
                //var userMode:IRCUserMode = parseUserMode(modeSrc, m);
                pushToServerLog(m);
            }
        }

        private function gotUserMode(m:IRCMessage):void
        {
            var modeSrc:String = m.params[0];
            // m.params.shift();
            //var userMode:IRCUserMode = parseUserMode(modeSrc, m);
            pushToServerLog(m);
        }

        private function gotChannelMode(m:IRCMessage):void
        {
            var channelName:String = m.params[0];
            var modeSrc:String     = m.params[1];

            if (channelName in _channels) {
                m.params.shift();
                m.params.shift();
                _channels[channelName].changedMode(modeSrc, m.params);
            } else {
                pushToServerLog(m);
            }
        }

        private function changedTopic(m:IRCMessage):void
        {
            var channelName:String = m.params[0];
            var topic:String       = m.trailing;

            if (channelName in _channels)
                _channels[channelName].topic = topic;
        }

        private function changedTopicToEmpty(m:IRCMessage):void
        {
            var channelName:String = m.params[0];
            if (channelName in _channels)
                _channels[channelName].topic = "";
        }

        private function changedNick(m:IRCMessage):void
        {
            var nick:String    = m.prefix.nick;
            var newNick:String = m.trailing;

            if (nick == _me.nick)
                _me.nick = newNick;

            if (nick in _privateTalks) {
                var pt:IRCPrivateTalk = _privateTalks[nick]
                pt.nick = newNick;
                _privateTalks[newNick] = pt;
                delete _privateTalks[nick];
            }


            for (var channelName:String in _channels)
                _channels[channelName].changedNick(nick, newNick);

            pushToServerLog(m);
        }

        private function receivedPartMessage(m:IRCMessage):void
        {
            var nick:String        = m.prefix.nick;
            var channelName:String = m.params[0];
            var message:String     = m.trailing;

            _channels[channelName].leaved(nick);

            if (nick == _me.nick) {
                delete _channels[channelName]
                // XXX: needs Event dispatch?
                // dispatchEvent(new IRCChannelEvent(IRCChannelEvent.PART,
                //     channelName));
            }
        }

        private function receivedAwayMessage(m:IRCMessage):void
        {
            //var target:String  = m.params[0];
            //var message:String = m.trailing;
            pushToServerLog(m);
        }

        private function registered():void
        {
            _isRegistered = true;
            dispatchEvent(new IRCEvent(IRCEvent.REGISTERED));

            for each(var channelName:String in _serverSetting.presetChannels)
                join(channelName);
        }

        private function pushToServerLog(m:IRCMessage):void
        {
            _serverLogger.receivedMessage(m);
        }

        private function receivedHandler(e:IRCEvent):void
        {
            var m:IRCMessage = e.message;

            switch (m.command) {
                // initiating connection
                case NumericReplies.RPL_WELCOME:
                    _me = IRCUtil.parseWelcomeMessage(m.trailing);
                    if (_me == null)
                        disconnect();
                case NumericReplies.RPL_YOURHOST:
                case NumericReplies.RPL_CREATED:
                case NumericReplies.RPL_MYINFO:
                case NumericReplies.RPL_ISUPPORT:
                    _registered++;
                    if (!_isRegistered && _registered >= 4)
                        registered();
                    break;

                case IRCCommands.NICK:
                    changedNick(m);
                    break;
                case NumericReplies.ERR_NICKNAMEINUSE:
                case NumericReplies.ERR_NICKCOLLISION:
                    // retryNick with appending "_"
                    retryNick(m);
                    break;

                case IRCCommands.JOIN:
                    // joined channel successfully
                    joinedChannel(m);
                    break;
                case NumericReplies.RPL_NAMREPLY:
                    // response for NAMES or JOIN
                    // list of channel members
                    rememberChannelMembers(m);
                    break;
                case NumericReplies.RPL_ENDOFNAMES:
                    updateChannelMembers(m);
                    break;

                case IRCCommands.PRIVMSG:
                    receivedPRIVMSG(m);
                    break;
                case IRCCommands.NOTICE:
                    receivedNOTICE(m);
                    break;

                case IRCCommands.PING:
                    // reply PONG
                    pong();
                    break;

                case IRCCommands.MODE:
                    changedMode(m);
                    break;
                case NumericReplies.RPL_UMODEIS:
                    // get user's mode
                    gotUserMode(m);
                    break;
                case NumericReplies.RPL_CHANNELMODEIS:
                    // get channel mode
                    gotChannelMode(m);
                    break;

                case NumericReplies.RPL_TOPIC:
                    changedTopic(m);
                    break;

                case NumericReplies.RPL_NOTOPIC:
                    changedTopicToEmpty(m);
                    break;

                case NumericReplies.RPL_AWAY:
                    // send message, but he is away
                    receivedAwayMessage(m);
                    break;
                case NumericReplies.RPL_NOWAWAY:
                    // Now my status is away
                    break;
                case NumericReplies.RPL_UNAWAY:
                    // Now my status is not away
                    break;

                case IRCCommands.PART:
                    receivedPartMessage(m);
                    break;
                default:
                    pushToServerLog(m);
            }
        }

        private function connectHandler(e:Event):void
        {
            if (_serverSetting.password != null && _serverSetting.password.length > 0)
                _connection.sendMessage(IRCCommands.PASS,
                    [_serverSetting.password]);
            _connection.sendMessage(IRCCommands.NICK,
                [_serverSetting.nickname]);
            _connection.sendMessage(IRCCommands.USER,
                [_serverSetting.username, _serverSetting.usermode, "*"],
                _serverSetting.realname);
            dispatchEvent(e);
        }

        private function closeHandler(e:Event):void
        {
            dispose();
            dispatchEvent(e);
            // auto reconnection
            var canRetry:Boolean = _reconnectionManager.saveRecordAndVerify();
            if (canRetry) {
                connect();
            } else {
                _reconnectionManager.clear();
            }
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            dispose();
            dispatchEvent(e);
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            dispose();
            dispatchEvent(e);
        }
    }
}

