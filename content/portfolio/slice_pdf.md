---
title: "PDF 페이지 조각내기"
date: 2020-01-03T01:32:02+09:00
tags: []
draft: false
---
PDF 책의 각 페이지를 가로로 눕혀 반으로 잘라, 다시 PDF로 묶어내는 쉘 스크립트입니다.

<!--mor -->

화면이 작은 전자책에서 A4 또는 Letter 사이즈 PDF 책을 편하게 읽기위해 간단히 만들어 본것으로,

* 책한권 내 페이지의 크기가 모두 동일한 경우 제대로 작동하는 버전으로, 이미 이북단말기에서 읽기 좀더 편하도록 각 페이지의 크기를 제각각 다르게 해 놓은 PDF 파일은 스크립트를 약간 손봐야 합니다.

* 와일드 카드를 사용해 한권으로 묶어내려니 메모리 부족/오픈파일 갯수 초과 등으로 제대로 작업이 안되는 관계로, 약간은 무식하게 처리한 방법입니다.

~~~
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
~~~
