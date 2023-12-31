#!/usr/bin/env bash

URL="https://www-cs-faculty.stanford.edu/~knuth"
TAOCP_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
#DIFF_PDF=diff-pdf/diff-pdf
TODAY=`date +%Y%m%d`
NEW_UPDATES=

get_pdf_pages() {
    PAGES_COUNT=$(pdfinfo $1 2>/dev/null | grep Pages | tr -s " " | cut -d " " -f 2)
    return ${PAGES_COUNT:-0}
}

for code in {7..20}; do
    for letter in a b c; do
    FASC=fasc${code}${letter}
        FASC_GZ=$FASC.ps.gz
        OLD_MD5=`sha1sum $TAOCP_DIR/$FASC_GZ 2>/dev/null | cut -d' ' -f1`
        wget -q $URL/$FASC_GZ -O $TAOCP_DIR/$FASC_GZ
        NEW_MD5=`sha1sum $TAOCP_DIR/$FASC_GZ 2>/dev/null | cut -d' ' -f1`

        if [ ! -s $TAOCP_DIR/$FASC_GZ ]; then
            rm $TAOCP_DIR/$FASC_GZ
        else
            echo -n "Updating $FASC... "

            if [ ! $OLD_MD5 ] || [ $OLD_MD5 != $NEW_MD5 ]; then
                FASC_PDF=$FASC-$TODAY.pdf
                gunzip -c $TAOCP_DIR/$FASC_GZ | ps2pdf - > $TAOCP_DIR/$FASC_PDF
                if [ ! $OLD_MD5 ]; then
                    echo -en '**\e[5;32mNEW!\e[0m** (Please update the report manually)'
                else
                    echo -en '\e[5;33mUPDATED!\e[0m'
                fi

                get_pdf_pages $TAOCP_DIR/$FASC
                OLD_PAGES_COUNT=$?
                get_pdf_pages $TAOCP_DIR/$FASC_PDF
                NEW_PAGES_COUNT=$?
                echo -n " :: +$(($NEW_PAGES_COUNT-$OLD_PAGES_COUNT)) pages"

                sed -i "/$FASC.pdf/{p;N;s:<td>.*</td>:<td>$NEW_PAGES_COUNT</td>:}" $TAOCP_DIR/taocp.html
                ln -sf $TAOCP_DIR/$FASC_PDF $TAOCP_DIR/$FASC
            fi
            echo
        fi
    done
done


sed -i "/Revision date/s:....-..-..:$TODAY:" $TAOCP_DIR/taocp.html
