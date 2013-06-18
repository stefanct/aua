PROJ := aua
TEX := pdflatex -shell-escape
#shell escape needed for epstopdf
BIB := bibtex
IDX := makeindex
#VIEW := "/cygdrive/c/Program\ Files/Composing/Foxit\ Reader/Foxit\ Reader.exe"
#VIEW := "c:\\\\Program\ Files\\\\Composing\\\\Foxit\ Reader\\\\Foxit\ Reader.exe"
VIEW := "gnome-open"
CWD := $(shell pwd)
TEX_MAIN := aua-doku
TEX_OUT := $(TEX_MAIN).pdf


#all: $(TEX_OUT)
all: view

fast:
	$(TEX) $(TEX_MAIN).tex
	"$(VIEW)" "$(CWD)/${TEX_OUT}"

view: clean $(TEX_OUT) 
	"$(VIEW)" "$(CWD)/${TEX_OUT}"
	
clean:
	rm -rf *.aux *.bbl *.idx *.ilg *.blg *.alg *.ind *.toc *.acl *.out *.log ./images/*.pdf $(TEX_OUT) $(PROJ).tgz

$(PROJ).tgz: clean
	tar -zcvf $@ *	

%.pdf: aua-doku.tex
	#~ ./makeacro $(TEX_MAIN).tex
	$(TEX) $(basename $@).tex
	#~ $(BIB) $(TEX_MAIN)
	#~ $(IDX) $(TEX_MAIN).idx
	#~ $(TEX) $(basename $@).tex
	#~ $(TEX) $(basename $@).tex

.PHONY = clean view all fast
