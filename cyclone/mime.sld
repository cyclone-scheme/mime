
(define-library (cyclone mime)
  (export assq-ref mime-header-fold mime-headers->list
          mime-parse-content-type mime-decode-header
          mime-message-fold mime-message->sxml mime-write-headers)
  (import (scheme base) (scheme char) (scheme write)
          (cyclone base64) (cyclone quoted-printable)
          (cyclone string))
  (include "mime.scm"))
