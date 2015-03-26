import com.ericsson.otp.erlang.*;

public class JavaNode
{

   public final String nodeName;
   public final String processName;

   public JavaNode(String nodeName, String processName) throws Exception
   {
      this.nodeName = nodeName;
      this.processName = processName;
   }

   public void start() throws Exception
   {
      log(this.nodeName + " startd!");
      this.loop();
   }

   public void loop() throws Exception
   {
      OtpNode otpNode = new OtpNode(this.nodeName);
      OtpMbox otpMbox = otpNode.createMbox(this.processName);

      OtpErlangObject incomingObject;
      OtpErlangTuple incomingMsg;
      OtpErlangPid incomingMsgSender;
      OtpErlangBinary incomingMsgBody;
      

      while(true)
      {
         incomingObject = otpMbox.receive();
         incomingMsg = (OtpErlangTuple) incomingObject;
         incomingMsgSender = (OtpErlangPid) incomingMsg.elementAt(0);
         incomingMsgBody = (OtpErlangBinary) incomingMsg.elementAt(1);
         otpMbox.send(incomingMsgSender, incomingMsg);

      }
   }

   public static void log(String log)
   {
      System.out.println(log);
   }

   public static void main(String[] args) throws Exception
   {
      if(args.length != 2)
      {
         log("Proper usage is: java JavaNode {node-name} {process-name}");
         System.exit(0);
      }
      
      try {
         JavaNode javaNode = new JavaNode(args[0], args[1]);
         javaNode.start();
      } catch (Exception e) {
         log("Exception: " + e);
         System.exit(0);
      }
   }
}
