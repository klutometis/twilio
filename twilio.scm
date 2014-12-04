(module twilio
  (twilio-sid
   twilio-auth
   twilio-from
   twilio-url
   twilio-make-call
   twilio-send-sms
   twilio-write
   twilio-response
   twilio-say
   twilio-play
   twilio-sms)

  (import chicken
          data-structures
          scheme)

  (require-library htmlprag)
  (import (only htmlprag write-shtml-as-html))
  
  (use extras
       http-client
       matchable
       s
       srfi-1)

  (include "twilio-core.scm"))
