@(egg "twilio")
@(description "Twilio bindings")
@(author "Peter Danenberg")
@(email "pcd@roxygen.org")
@(username "klutometis")
@(noop)

(define twilio-sid
  (make-parameter (get-environment-variable "TWILIO_SID")))

(define twilio-auth
  (make-parameter (get-environment-variable "TWILIO_AUTH")))

(define twilio-from
  (make-parameter (get-environment-variable "TWILIO_FROM")))

(define twilio-url
  (make-parameter "https://~a:~a@api.twilio.com/2010-04-01/Accounts/~a/~a"))
