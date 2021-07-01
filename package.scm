(package
 (name           mime)
 (version        "0.2.0")
 (license        "BSD")
 (authors        "Alex Shinn")
 (maintainers    "Justin Ethier <justin.ethier at gmail dot com>")
 (description    "A library to parse MIME headers and bodies into SXML")
 (tags           "networking")
 (docs           "https://github.com/cyclone-scheme/mime")
 (test           "mime-test.scm")
 (dependencies   (base64 quoted-printable string))

 (library
     (name (cyclone mime))
   (description "A library to parse MIME headers and bodies into SXML")))
