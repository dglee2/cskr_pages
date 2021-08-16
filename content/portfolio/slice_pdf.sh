#!/bin/sh

PWD=`pwd`
PDF_FILENAME=${1%%.pdf}
NEW_SIZE=1
TMP_DIR=$PWD/tmp-$PDF_FILENAME

echo "EXTRACTING PAGE TO IMAGE..." && \
mkdir $TMP_DIR && pdftoppm -png $1 $TMP_DIR/p && \
{
	FIRST_FILE=`ls $TMP_DIR/p-* | head -n 1`
	IMAGE_H=`identify $FIRST_FILE | cut -d ' ' -f 3 | cut -d x -f 2`
	IMAGE_W=`identify $FIRST_FILE | cut -d ' ' -f 3 | cut -d x -f 1`
	H_ODD=$(($IMAGE_H%2))
	H_HALF=$(($IMAGE_H/2))

	if [ $H_ODD > 0 ]; then
		H_HALF=$(($H_HALF+1))
	fi
	NEW_SIZE=`echo $H_HALF'x'$IMAGE_W`
} && cd $TMP_DIR && \
{
	for IMAGE_FILE in `ls p-*`
	do
		convert $IMAGE_FILE -rotate 270 r-$IMAGE_FILE && echo "ROTATE "$IMAGE_FILE
	done
} && \
{
	for IMAGE_FILE in `ls r-*`
	do
		convert $IMAGE_FILE -crop $NEW_SIZE out-$IMAGE_FILE && echo "CROP "$IMAGE_FILE
	done
} && \
{
	for IMAGE_FILE in `ls out-*`
	do
		convert $IMAGE_FILE -page $NEW_SIZE $IMAGE_FILE.pdf && echo "IMAGE TO PDF PAGE "$IMAGE_FILE
	done
} && \
{
	FIRST_PDF_PAGE=`ls out-*.pdf | head -n 1`
	PAGE_COUNTER=1
	BOOK_COUNTER=1
	mv $FIRST_PDF_PAGE out.pdf && \
	{
	for PDF_PAGE in `ls out-*.pdf`
	do
		echo "PROCESSING BOOK "$BOOK_COUNTER",PAGE "$PAGE_COUNTER
		if [ $PAGE_COUNTER -eq 100 ]; then
			mv out.pdf ../$PDF_FILENAME-$BOOK_COUNTER.pdf && mv $PDF_PAGE out.pdf
			BOOK_COUNTER=$(($BOOK_COUNTER+1))
			PAGE_COUNTER=1
		else
			pdfunite out.pdf $PDF_PAGE out2.pdf && mv out2.pdf out.pdf
			PAGE_COUNTER=$(($PAGE_COUNTER+1))
		fi
	done
	} && \
	if [ -e out.pdf ]; then
		mv out.pdf ../$PDF_FILENAME-$BOOK_COUNTER.pdf
	fi
} && echo "ALL DONE"
