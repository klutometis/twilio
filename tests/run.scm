(use test
     twilio)

(test "Twilio write, response, say"
      "<Response><Say voice=\"alice\" loop=\"2\" language=\"de\">harro</Say></Response>"
      (with-output-to-string
        (lambda ()
          (twilio-write
           (twilio-response
            (twilio-say "harro" voice: "alice" loop: "2" language: "de"))))))
