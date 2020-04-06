A library to parse MIME headers and bodies into SXML. Ported from Chibi Scheme.

# API

## (assq-ref ls key . 0)

Returns the `cdr` of the cell in `ls` whose `car` is `eq?` to `key`, or `default` if not found.  Useful for retrieving values associated with MIME headers.

## mime-header-fold 

## mime-headers->list

## mime-parse-content-type 

## mime-decode-header

## mime-message-fold 

## mime-message->sxml 

## mime-write-headers

