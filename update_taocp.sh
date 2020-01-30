#!/bin/bash

URL="http://www-cs-faculty.stanford.edu/~uno"
TAOCPDIR=.
DIFFPDF=diff-pdf/diff-pdf
NEW_UPDATES=

for code in `seq 7 10`; do
    for letter in a b c; do
        FASC=fasc${code}${letter}.ps.gz
        OLDMD5=`sha1sum $TAOCPDIR/$FASC 2>/dev/null | cut -d' ' -f1`
        wget -q $URL/$FASC -O $TAOCPDIR/$FASC
        if [ ! -s $TAOCPDIR/$FASC ]; then
            rm $TAOCPDIR/$FASC
        else
            NEWMD5=`sha1sum $TAOCPDIR/$FASC 2>/dev/null | cut -d' ' -f1`
            echo -n "Checking ${FASC%.ps.gz}... "
            if [ ! $OLDMD5 ] || [ $OLDMD5 != $NEWMD5 ]; then
                echo -n "UPDATED!"
                FASCPDF=${FASC%ps.gz}pdf
                if [ -f $TAOCPDIR/$FASCPDF ]; then
                    mv $TAOCPDIR/$FASCPDF $TAOCPDIR/${FASCPDF%.pdf}_old.pdf
                fi
                gunzip -c $TAOCPDIR/$FASC | ps2pdf - > $TAOCPDIR/$FASCPDF

                PAGE_COUNT=`pdfinfo $TAOCPDIR/$FASCPDF | grep Pages | tr -s " " | cut -d " " -f 2`

                sed -i "/$FASCPDF/{p;N;s:<td>.*</td>:<td>$PAGE_COUNT</td>:}" $TAOCPDIR/taocp.html

                #$DIFFPDF --output-diff=${FASCPDF%.pdf}_diff.pdf $TAOCPDIR/${FASCPDF%.pdf}_old.pdf $TAOCPDIR/$FASCPDF
                NEW_UPDATES="$NEW_UPDATES ${FASC%.ps.gz}"
            fi
            echo
        fi
    done
done

if [ "$NEW_UPDATES" ]; then
    echo UPDATED $NEW_UPDATES !!!
    #notifu-1.6/notifu64 /t info /p "New updates for TAoCP!" /m "The following fascicles got updated:$NEW_UPDATES"
fi

CURRENT_DATE=`date +%Y-%m-%d`
sed -i "/Revision date/s:....-..-..:$CURRENT_DATE:" $TAOCPDIR/taocp.html
