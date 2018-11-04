#!/bin/sh

#if [ $# -ne 1 ]; then
#    echo "Syntax: [latex filename]"
#    exit 1
#fi

filename='astropedia.tex'
#filename=${1}
filename_noext=`echo ${filename} | sed -e "s/.tex//"`

#chapter bibliography
chaptbib=$false



# start compiling

pdflatex ${filename_noext}

if [ $chaptbib ]
then
#Run bibtex on all necessary chapters - only able to ignore commented chapters when the % is the first character on the line!:
grep -v "^%" ${filename} | grep "include{" | awk '$0=$2' FS='{' RS='}' | while read line
do
    #check if tex file exists:
    if [ ! -e "${line}.tex" ]; then
	echo "${line}.tex does not exist! Exiting..."
	exit 1
    fi
    #Check if file has a \bibliography command - only able to ignore commented bibliographies when the % is the first character on the line!:
    numbibs=`grep -v "^%" ${line}.tex | grep "bibliography{" | wc -l`
    if [ ${numbibs} -ge 1 ]; then
	bibtex ${line}
    fi
    if [${numbibs} -gt 1 ]; then
	echo "Warning: More than one bibliography found in ${line}.tex"
    fi
done

# just one bibliography at the end of documents
else
    bibtex ${filename_noext}
fi

pdflatex ${filename_noext}
pdflatex ${filename_noext}
#dvipdf ${filename_noext}.dvi
#evince ${filename_noext}.pdf

exit 0
