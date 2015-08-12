GRAPHICS=1
ia.native: ia.ml data.ml geometry.ml piece.ml board.ml common_types.mli gen.ml gui.ml graph.ml
ifeq ($(GRAPHICS),1)
	cp gui_graphics.ml gui.ml
	ocamlbuild -use-ocamlfind -pkgs camlimages.core,camlimages.png,camlimages.graphics,unix,str,graphics,yojson ia.native
else
	cp gui_dummy.ml gui.ml
	ocamlbuild -pkgs str,yojson ia.native
endif

ia.d.byte: ia.ml data.ml geometry.ml piece.ml board.ml common_types.mli gen.ml gui.ml
	cp gui_graphics.ml gui.ml
	ocamlbuild -use-ocamlfind -pkgs str,graphics,yojson ia.d.byte

clean:
	rm -rf _build ia.native ia.d.byte
