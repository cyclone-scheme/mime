
# mime

## Index 
- [Intro](#Intro)
- [Dependencies](#Dependencies)
- [Test dependencies](#Test-dependencies)
- [Foreign dependencies](#Foreign-dependencies)
- [API](#API)
- [Examples](#Examples)
- [Author(s)](#Authors)
- [Maintainer(s)](#Maintainers)
- [Version](#Version) 
- [License](#License) 
- [Tags](#Tags) 

## Intro 
A library to parse MIME headers and bodies into SXML. Ported from Chibi Scheme.

## Dependencies 
base64 quoted-printable string

## Test-dependencies 
None

## Foreign-dependencies 
None

## API 

### (cyclone base64)

#### [procedure] `(assq-ref ls key . 0)`

Returns the `cdr` of the cell in `ls` whose `car` is `eq?` to `key`, or `default` if not found.  Useful for retrieving values associated with MIME headers.

#### [procedure] `(mime-header-fold kons knil [source [limit [kons-from]]])`

Performs a fold operation on the MIME headers of source which can be
either a string or port, and defaults to current-input-port.  `kons`
is called on the three values:
   
    (kons header value accumulator)

where accumulator begins with `knil`.  Neither the header nor the
value are modified, except wrapped lines are handled for the value.

The optional procedure `kons-from` is a procedure to be called when
the first line of the headers is an "From <address> <date>" line, to
enable this procedure to be used as-is on mbox files and the like.
It defaults to `kons`, and if such a line is found the fold will begin
with `(kons-from '%from <address> (kons-from '%date <date> knil))`.

The optional `limit` gives a limit on the number of headers to read.

#### [procedure] `(mime-headers->list [source])`

Return an alist of the MIME headers from source with headers all downcased.

#### [procedure] `(mime-parse-content-type str)`
Parses `str` as a Content-Type style-value returning the list `(type (attr . val) ...)`.

#### [procedure] `(mime-decode-header str)`
Replace all occurrences of RFC1522 escapes in `str` with the appropriate decoded and charset converted value.

#### [procedure] `(mime-message-fold src kons knil [down up headers])`
Performs a tree fold operation on the given string or port
`src` as a MIME body corresponding to the headers give in
`headers`.  If `headers` are false or not provided they
are first read from `src`.

`kons` is called on the successive values:

    (kons parent-headers part-headers part-body accumulator)

where `part-headers` are the headers for the given MIME part (the
original headers for single-part MIME), `part-body` is the
appropriately decoded and charset-converted body of the message,
and the `accumulator` begins with `knil`.

If a multipart body is found, then a tree fold is performed,
calling `down` once to get a new accumulator to pass to
`kons`, and `up` on the result when returning.  Their
signatures are:

    (down headers seed)
    (up headers parent-seed seed)

The default `down` simply returns null, and the default
`up` wraps the seed in the following sxml:

   ((mime (@ headers ...)
      seed ...)
    parent-seed ...)

#### [procedure] `(mime-message->sxml [src [headers]])`
Parse the given source as a MIME message and return the result as an SXML object of the form:

    (mime (@ (header . value) ...) parts ...)

#### [procedure] `(mime-write-headers headers out)`
Write out an alist of headers in mime format.

## Examples
```scheme
(import (scheme base) (cyclone mime) (cyclone string) (cyclone test))
(test-group "mime"

      (test '(text/html (charset . "UTF-8") (filename . "index.html"))
          (mime-parse-content-type
           "text/html; CHARSET=UTF-8; filename=index.html"))

      (test '(multipart/form-data (boundary . "AaB03x"))
          (mime-parse-content-type "multipart/form-data, boundary=AaB03x"))

      (test '(mime (@ (from . "\"Dr. Watson <guest@grimpen.moor>\"")
                      (to . "\"Sherlock Homes <not-really@221B-baker.street>\"")
                      (subject . "\"First Report\"")
                      (content-type . "text/plain; charset=\"ISO-8859-1\""))
                   "Moor is gloomy. Heard strange noise, attached.\n")
          (call-with-input-string
              "From:    \"Dr. Watson <guest@grimpen.moor>\"
To:      \"Sherlock Homes <not-really@221B-baker.street>\"
Subject: \"First Report\"
Content-Type: text/plain; charset=\"ISO-8859-1\"

Moor is gloomy. Heard strange noise, attached.

"
            mime-message->sxml))

      ;; from rfc 1867

      (test '(mime
              (@ (content-type . "multipart/form-data, boundary=AaB03x"))
              (mime (@ (content-disposition . "form-data; name=\"field1\""))
                    "Joe Blow")
              (mime (@ (content-disposition
                        . "form-data; name=\"pics\"; filename=\"file1.txt\"")
                       (content-type . "text/plain"))
                    " ... contents of file1.txt ..."))
          (call-with-input-string
              "Content-type: multipart/form-data, boundary=AaB03x

--AaB03x
content-disposition: form-data; name=\"field1\"

Joe Blow
--AaB03x
content-disposition: form-data; name=\"pics\"; filename=\"file1.txt\"
Content-Type: text/plain

 ... contents of file1.txt ...
--AaB03x--
"
            mime-message->sxml))

      (test '(mime
              (@ (content-type . "multipart/form-data, boundary=AaB03x"))
              (mime (@ (content-disposition . "form-data; name=\"field1\""))
                    "Joe Blow")
              (mime (@ (content-disposition . "form-data; name=\"pics\"")
                       (content-type . "multipart/mixed, boundary=BbC04y"))
                    (mime (@ (content-disposition
                              . "attachment; filename=\"file1.txt\"")
                             (content-type . "text/plain"))
                          "... contents of file1.txt ...")
                    (mime (@ (content-disposition
                              . "attachment; filename=\"file2.gif\"")
                             (content-type . "image/gif")
                             (content-transfer-encoding . "binary"))
                          #u8(32 32 46 46 46 99 111 110 116 101 110
                                 116 115 32 111 102 32 102 105 108 101
                                 50 46 103 105 102 46 46 46))))
          (call-with-input-string
              "Content-type: multipart/form-data, boundary=AaB03x

--AaB03x
content-disposition: form-data; name=\"field1\"

Joe Blow
--AaB03x
content-disposition: form-data; name=\"pics\"
Content-type: multipart/mixed, boundary=BbC04y

--BbC04y
Content-disposition: attachment; filename=\"file1.txt\"
Content-Type: text/plain

... contents of file1.txt ...
--BbC04y
Content-disposition: attachment; filename=\"file2.gif\"
Content-type: image/gif
Content-Transfer-Encoding: binary

  ...contents of file2.gif...
--BbC04y--
--AaB03x--
"
            mime-message->sxml))

      (test '(mime
              (@ (content-type . "multipart/form-data, boundary=AaB03x"))
              (mime (@ (content-disposition . "form-data; name=\"field1\"")
                       (content-type . "text/plain"))
                    "Joe Blow")
              (mime (@ (content-disposition . "form-data; name=\"pics\"")
                       (content-type . "multipart/mixed, boundary=BbC04y"))
                    (mime (@ (content-disposition
                              . "attachment; filename=\"file1.txt\"")
                             (content-type . "text/plain"))
                          "... contents of file1.txt ...")
                    (mime (@ (content-disposition
                              . "attachment; filename=\"file2.gif\"")
                             (content-type . "image/gif")
                             (content-transfer-encoding . "binary"))
                          #u8(32 32 46 46 46 99 111 110 116 101 110
                                 116 115 32 111 102 32 102 105 108 101
                                 50 46 103 105 102 46 46 46))))
          (mime-message->sxml
           (open-input-bytevector
            (string->utf8
             "Content-type: multipart/form-data, boundary=AaB03x

--AaB03x
content-disposition: form-data; name=\"field1\"
Content-Type: text/plain

Joe Blow
--AaB03x
content-disposition: form-data; name=\"pics\"
Content-type: multipart/mixed, boundary=BbC04y

--BbC04y
Content-disposition: attachment; filename=\"file1.txt\"
Content-Type: text/plain

... contents of file1.txt ...
--BbC04y
Content-disposition: attachment; filename=\"file2.gif\"
Content-type: image/gif
Content-Transfer-Encoding: binary

  ...contents of file2.gif...
--BbC04y--
--AaB03x--
"))))
)

(test-exit)
```

## Author(s)
Alex Shinn

## Maintainer(s) 
Justin Ethier

## Version 
"0.2.0"

## License 
BSD

## Tags 
networking

