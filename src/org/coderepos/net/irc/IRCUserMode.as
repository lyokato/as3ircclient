package org.coderepos.net.irc
{
    public class IRCUserMode
    {
       public static const NUM_NORMAL:String    = "0";
       public static const NUM_INVISIBLE:String = "8";

       public static const OP_PLUS:String  = "+";
       public static const OP_MINUS:String = "-";

       private var _opType:String;

       public function IRCUserMode(opType:String)
       {
            _opType = opType;
       }

       public function get isPlus():Boolean
       {
            return (_opType == OP_PLUS);
       }

    }
}

