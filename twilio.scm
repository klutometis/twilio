(module twilio
  (twilio-sid
   twilio-auth
   twilio-from
   twilio-url
   twilio-make-call
   twilio-send-sms)

  (import chicken
          data-structures
          scheme)

  (use debug
       extras
       http-client
       matchable
       s
       srfi-1)

  (include "twilio-core.scm"))
