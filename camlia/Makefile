ia.graphics.native: ia.ml data.ml geometry.ml piece.ml board.ml common_types.mli gen.ml gui.ml graph.ml gui_graphics.ml
	cp gui_graphics.ml gui.ml
	ocamlbuild -use-ocamlfind -pkgs camlimages.core,camlimages.png,camlimages.graphics,unix,str,graphics,yojson ia.native
	cp ia.native ia.graphics.native

ia.native: ia.ml data.ml geometry.ml piece.ml board.ml common_types.mli gen.ml gui.ml graph.ml gui_dummy.ml
	cp gui_dummy.ml gui.ml
	ocamlbuild -pkgs str,yojson ia.native

ia.latex.native: ia.ml data.ml geometry.ml piece.ml board.ml common_types.mli gen.ml gui.ml graph.ml gui_latex.ml
	cp gui_latex.ml gui.ml
	ocamlbuild -pkgs str,yojson ia.native
	cp ia.native ia.latex.native

ia.d.byte: ia.ml data.ml geometry.ml piece.ml board.ml common_types.mli gen.ml gui.ml
	cp gui_dummy.ml gui.ml
	ocamlbuild -use-ocamlfind -pkgs str,graphics,yojson ia.d.byte

ia.p.native: ia.ml data.ml geometry.ml piece.ml board.ml common_types.mli gen.ml gui.ml
	cp gui_dummy.ml gui.ml
	ocamlbuild -use-ocamlfind -pkgs str,graphics,yojson ia.p.native

clean:
	rm -rf _build ia.native ia.d.byte
