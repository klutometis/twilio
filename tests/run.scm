(use test
     twilio)

(test "Twilio write, response, say with parameters"
      "<Response><Say voice=\"alice\" loop=\"2\" language=\"de\">harro</Say></Response>"
      (with-output-to-string
        (lambda ()
          (twilio-write
           (twilio-response
            (twilio-say "harro" voice: "alice" loop: "2" language: "de"))))))

(test "Twilio write, response, SMS with no parameters"
      "<Response><Sms>harro</Sms></Response>"
      (with-output-to-string
        (lambda ()
          (twilio-write
           (twilio-response
            (twilio-sms "harro"))))))
