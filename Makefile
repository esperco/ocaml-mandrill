# OCaml interface to Mandrill's HTTP/JSON send interface

.PHONY: ml byte opt test install clean

default: byte opt

ML = \
  mandrill_date.ml mandrill_json.ml \
  mandrill_t.mli mandrill_t.ml \
  mandrill_v.mli mandrill_v.ml \
  mandrill_j.mli mandrill_j.ml \
  mandrill.mli mandrill.ml

INSTALL_CANDIDATES = \
  mandrill_date.ml mandrill_json.ml *.mli \
  *.cmi *.cmx *.o *.cma *.cmxa *.a

ml:
	atdgen -t -j-std mandrill.atd
	atdgen -j -j-std mandrill.atd
	atdgen -v -j-std mandrill.atd

byte: ml
	ocamlfind ocamlc -a -g $(ML) -o mandrill.cma -package atdgen,unix

opt: ml
	ocamlfind opt -a -g $(ML) -o mandrill.cmxa -package atdgen,unix

install:
	ocamlfind install mandrill META \
          `find $(INSTALL_CANDIDATES) | grep -v '^test_'`

uninstall:
	ocamlfind remove mandrill

test: opt
	ocamlfind opt -g mandrill.cmxa test_mandrill.ml \
	  -o test_mandrill.opt \
	  -package atdgen,unix,cohttp.lwt -linkpkg
	./test_mandrill.opt -conf test.conf

clean:
	rm -f *.o *.a *.cm* *.opt *~ *.annot *_[tjv].mli *_[tjv].ml
