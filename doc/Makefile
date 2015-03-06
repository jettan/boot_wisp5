TARGET=thesis
TEXFILES=$(wildcard *.tex)
LATEXOPTIONS= --output-directory=./work --shell-escape
LATEXPATH=.:./template:./chapters:${TEXINPUTS}
all:   pdflatex
 
dvipdf:   dvi
	@dvipdf work/${TARGET}.dvi

pdflatex:
	@TEXINPUTS=${LATEXPATH} pdflatex ${LATEXOPTIONS} ${TARGET}.tex
	@if grep -q '\\citation' work/*.aux ; then cd ./work; bibtex ${TARGET}; cd .. ; fi
	@TEXINPUTS=${LATEXPATH} pdflatex ${LATEXOPTIONS} ${TARGET}.tex
	@TEXINPUTS=${LATEXPATH} pdflatex ${LATEXOPTIONS} ${TARGET}.tex
	@TEXINPUTS=${LATEXPATH} pdflatex ${LATEXOPTIONS} ${TARGET}.tex
	@mv work/${TARGET}.pdf .
 
spell: *.tex
	@for file in $?; do aspell --lang=en_GB --mode=tex -c $$file; done
 
dvi:
	@TEXINPUTS=${LATEXPATH} latex ${LATEXOPTIONS} ${TARGET}.tex
	@if grep -q '\\citation' work/*.aux ; then cd ./work; bibtex ${TARGET}; cd .. ; fi
	@TEXINPUTS=${LATEXPATH} latex ${LATEXOPTIONS} ${TARGET}.tex
	@TEXINPUTS=${LATEXPATH} latex ${LATEXOPTIONS} ${TARGET}.tex
	@TEXINPUTS=${LATEXPATH} latex ${LATEXOPTIONS} ${TARGET}.tex

view: pdflatex
	evince ${TARGET}.pdf
 
clean:
	@-rm -f work/*.aux work/${TARGET}.log work/*.bak work/${TARGET}.dvi work/${TARGET}.pdf ${TARGET}.pdf work/${TARGET}.toc work/${TARGET}.bbl work/${TARGET}.blg work/${TARGET}.out ${TARGET}.toc ${TARGET}.bbl ${TARGET}.blg ${TARGET}.out ${TARGET}.log
 
.PHONY: clean,spell,dvi,pdf,view
