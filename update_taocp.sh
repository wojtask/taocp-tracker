#!/bin/bash

URL="http://www-cs-faculty.stanford.edu/~uno"
TAOCPDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
DIFFPDF=diff-pdf/diff-pdf
NEW_UPDATES=

for code in {7..9}; do
    for letter in a b c; do
        FASC=fasc${code}${letter}.ps.gz
        OLDMD5=`sha1sum $TAOCPDIR/$FASC 2>/dev/null | cut -d' ' -f1`
        wget -q $URL/$FASC -O $TAOCPDIR/$FASC

        if [ ! -s $TAOCPDIR/$FASC ]; then
            rm $TAOCPDIR/$FASC
        else
            NEWMD5=`sha1sum $TAOCPDIR/$FASC 2>/dev/null | cut -d' ' -f1`
            echo -n "Checking ${FASC%.ps.gz}... "

            if [ ! $OLDMD5 ]; then
                echo -en '**\e[5;32mNEW!\e[0m** (Please update the report manually)'
            elif [ $OLDMD5 != $NEWMD5 ]; then
                echo -en '\e[5;33mUPDATED!\e[0m'
            fi

            if [ ! $OLDMD5 ] || [ $OLDMD5 != $NEWMD5 ]; then
                FASCPDF=${FASC%ps.gz}pdf
                if [ -f $TAOCPDIR/$FASCPDF ]; then
                    mv $TAOCPDIR/$FASCPDF $TAOCPDIR/${FASCPDF%.pdf}_old.pdf
                fi
                gunzip -c $TAOCPDIR/$FASC | ps2pdf - > $TAOCPDIR/$FASCPDF

                PAGE_COUNT=`pdfinfo $TAOCPDIR/$FASCPDF | grep Pages | tr -s " " | cut -d " " -f 2`

                sed -i "/$FASCPDF/{p;N;s:<td>.*</td>:<td>$PAGE_COUNT</td>:}" $TAOCPDIR/taocp.html
            fi
            echo
        fi
    done
done

CURRENT_DATE=`date +%Y-%m-%d`
sed -i "/Revision date/s:....-..-..:$CURRENT_DATE:" $TAOCPDIR/taocp.html
