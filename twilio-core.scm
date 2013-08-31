@(heading "Abstract")

@(text "[[http://www.twilio.com/|Twilio]] allows one to send SMSes and
place calls using their API; and the {{twilio}} egg requires at least three
pieces of information to do so:

* The account SID
* The auth token
* The from number

They are populated initially from the environment
variables {{TWILIO_SID}}, {{TWILIO_AUTH}}, {{TWILIO_FROM}};
respectively. It is also possible to set the dynamic
parameters {{twilio-sid}}, {{twilio-auth}}, {{twilio-from}}.")

@(heading "Documentation")

(define twilio-sid
  @("The Twilio account SID")
  (make-parameter (get-environment-variable "TWILIO_SID")))

(define twilio-auth
  @("The Twilio auth token")
  (make-parameter (get-environment-variable "TWILIO_AUTH")))

(define twilio-from
  @("The phone number from which to post")
  (make-parameter (get-environment-variable "TWILIO_FROM")))

(define twilio-url
  @("The Twilio API URL")
  (make-parameter "https://~a:~a@api.twilio.com/2010-04-01/Accounts/~a/~a"))

(define (twilio-url-calls)
  (format (twilio-url) (twilio-sid) (twilio-auth) (twilio-sid) "Calls"))

(define (twilio-url-sms)
  (format (twilio-url) (twilio-sid) (twilio-auth) (twilio-sid) "/SMS/Messages"))

(define (filter-parameters parameters)
  (filter (match-lambda
            ;; These are SHTML attributes: (<symbol> <string>).
            ((key value) value)
            ;; These are POST parameters: (<string> . <string>).
            ((key . value) value))
          parameters))

(define (case-map-parameters map-case parameters)
  (map (match-lambda
         ;; These are SHTML attributes: (<symbol> <string>).
         ((key value)
          (list (string->symbol (map-case (symbol->string key))) value))
         ;; These are POST parameters: (<string> . <string>).
         ((key . value)
          (cons (map-case (symbol->string key)) value)))
       parameters))

(define (upper-camel-filter-parameters parameters)
  (case-map-parameters s-upper-camel-case (filter-parameters parameters)))

(define (lower-camel-filter-parameters parameters)
  (case-map-parameters s-lower-camel-case (filter-parameters parameters)))

(define (twilio-make-call to
                          #!key
                          url
                          application-sid
                          method
                          fallback-url
                          fallback-method
                          status-callback
                          status-callback-method
                          send-digits
                          if-machine
                          timeout
                          record)
  @("Make a call using the Twilio API; see [[http://www.twilio.com/docs/api/rest/making-calls]]." ;
    (to "The phone number to call")
    (url "TwiML URL when the call connects")
    (application-sid "Alternatively, the app containing the URL")
    (method "Method to request {{url}}")
    (fallback-url "Second {{url}} to try")
    (fallback-method "Method to which to fall back")
    (status-callback "URL to post status to")
    (status-callback-method "Method to use")
    (send-digits "Keys to dial after connecting")
    (if-machine "Determine whether the caller is a machine")
    (timeout "How long to let the phone ring")
    (record "Whether to record the call")
    (@example-no-eval "Placing a call"
                      (twilio-make-call "+14158141829"
                                        url: "http://example.com/twiml.scm")))
  (let ((parameters `((from . ,(twilio-from))
                      (to . ,to)
                      (url . ,url)
                      (application-sid . ,application-sid)
                      (method . ,method)
                      (fallback-url . ,fallback-url)
                      (fallback-method . ,fallback-method)
                      (status-callback . ,status-callback)
                      (status-callback-method . ,status-callback-method)
                      (send-digits . ,send-digits)
                      (if-machine . ,if-machine)
                      (timeout . ,timeout)
                      (record . ,record))))
    (with-input-from-request
     (twilio-url-calls)
     (upper-camel-filter-parameters parameters)
     void)))

(define (twilio-send-sms to
                         body
                         #!key
                         status-callback
                         application-sid)
  @("Send an SMS using the Twilio API; see [[http://www.twilio.com/docs/api/rest/sending-sms]]."
    (to "The number to send to")
    (body "The SMS to send")
    (status-callback "POST when the message is processed")
    (application-sid "The application's SID")
    (@example-no-eval "Sending an SMS"
                      (twilio-send-sms "+14158141829"
                                       "If you wish to make an apple pie from scratch, you must first invent the universe.")))
  (let ((parameters `((from . ,(twilio-from))
                      (to . ,to)
                      (body . ,body)
                      (status-callback . ,status-callback)
                      (application-sid . ,application-sid))))
    (with-input-from-request
     (twilio-url-sms)
     (upper-camel-filter-parameters parameters)
     void)))

(define twilio-write
  @("Write STwiML as TwiML."
    (response "The STwiML response"))
  write-shtml-as-html)

(define (twilio-response . verbs)
  @("Wrap verbs in a STwiML response; see [[http://www.twilio.com/docs/api/twiml]]."
    (verbs "The verbs to wrap in a response")
    (@to "STwiML"))
  `(Response ,@verbs))

(define (twilio-say text #!key voice loop language)
  @("Say something; see [[http://www.twilio.com/docs/api/twiml/say]]."
    (text "The text to say")
    (voice "The voice to say it in")
    (loop "How many times to say it")
    (language "The language to say it in")
    (@to "STwiML"))
  (let ((parameters (lower-camel-filter-parameters
                     `((voice ,voice)
                       (loop ,loop)
                       (language ,language)))))
    (if (null? parameters)
        `(Say ,text)
        `(Say
          (,(string->symbol "@")
           ,@(lower-camel-filter-parameters parameters))
          ,text))))

(define (twilio-play url #!key loop)
  @("Play something; see [[http://www.twilio.com/docs/api/twiml/play]]."
    (url "The audio file to play")
    (loop "How many times to play it")
    (@to "STwiML"))
  (let ((parameters (lower-camel-filter-parameters
                     `((loop ,loop)))))
    (if (null? parameters)
        `(Play ,url)
        `(Play
          (,(string->symbol "@")
           ,@(lower-camel-filter-parameters parameters))
          ,url))))

(define (twilio-sms text #!key to from action method status-callback)
  @("Send an SMS; see [[http://www.twilio.com/docs/api/twiml/sms]]."
    (text "The text to send")
    (to "The number to send it to")
    (from "The number to send it from")
    (action "Action URL")
    (method "{{POST}} or {{GET}} for {{action}}")
    (status-callback "Status callback URL")
    (@to "STwiML"))
  (let* ((parameters (lower-camel-filter-parameters
                      `((to ,to)
                        (from ,from)
                        (action ,action)
                        (method ,method)
                        (status-callback ,status-callback)))))
    (if (null? parameters)
        `(Sms ,text)
        `(Sms (,(string->symbol "@")
               ,@(lower-camel-filter-parameters parameters))
              ,text))))
