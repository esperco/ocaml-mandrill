ocaml-mandrill
==============

OCaml client for sending email via the Mandrill service using HTTP
POST requests. This library helps your build well-formed requests and
parse the responses. It does not depend on a particular HTTP client.

Installation
------------

Requires atdgen and its dependencies:
```bash
opam install atdgen
make
make install
```

Documentation
-------------

Look into `mandrill.mli` and `mandrill.atd`.

Testing
-------

Testing requires Lwt and the Cohttp HTTP client:
```bash
opam install ssl conf-libev lwt cohttp
```

Create a config file with your API key and your email addresses:
```bash
cp sample.conf test.conf
# then edit test.conf
```

Build and run the test program:
```
make test
```
