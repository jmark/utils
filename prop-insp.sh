#!/usr/bin/bash

# ========================================================================== #
# init and global vars #
# ========================================================================== #

WIN_TITLE="Property Inspector"
FRM_TITLE="Common Properties"

FILE=$1;
if [ -e "${FILE}" ];
then
    FILE_DIR=$(dirname "${FILE}");
else
    echo "\"${FILE}\" does not exists!";
    exit 1;
fi
FILE=$(basename ${FILE});

FILE_META="${FILE_DIR}/.${FILE}.meta";

FILE_TAGS="${HOME}/scripts/tags.txt";
TMP_DIR="/tmp/${USER}/prop";
TMPF_FORM="${TMP_DIR}/form.txt";
TMPF_TAGS="${TMP_DIR}/tags.txt";
TMPF_COMMENTS="${TMP_DIR}/comments.txt";
TMPF_NEW_TAG="${TMP_DIR}/new_tag.txt";

FORM_INPUT['title']='default title';
FORM_INPUT['date']='default date';
FORM_INPUT['time']='default time';

mkdir -p "${TMP_DIR}";

# ========================================================================== #
# functions #
# ========================================================================== #

function form_dialog
{
    TMP_FILE="${TMPF_FORM}";

    dialog \
        --visit-items \
        --scrollbar \
        --no-mouse \
        --backtitle "${WIN_TITLE}" \
        --form "${FRM_TITLE}" 0 0 0 \
        "title"   2 4 "${FORM_INPUT['title']}" 2 15 90 0 \
        "date"    4 4 "${FORM_INPUT['date']}" 4 15 90 0 \
        "time"    6 4 "${FORM_INPUT['time']}" 6 15 90 0 \
         2> "${TMP_FILE}"

    return $?;
}

function tags_dialog
{
    TMP_FILE="${TMPF_TAGS}";

    IFS=$'\n'
    TAGS=($(cat "${FILE_TAGS}" | sort -n))
    unset IFS

    ARGS=()
    COUNT=0
    for EL in "${TAGS[@]}"
    do
        ARGS+=("${COUNT}" "${EL}" "off");
        ((COUNT++));
    done

    dialog \
        --visit-items \
        --scrollbar \
        --no-mouse \
        --backtitle "Dialog - Form sample" \
        --extra-button \
        --separate-output --buildlist "This is buildlist" 0 0 0 \
        "${ARGS[@]}" 2> ${TMP_FILE};

    return $?;
}

function add_new_tag_dialog
{
    TMP_FILE="${TMPF_NEW_TAG}";

    dialog \
        --visit-items \
        --scrollbar \
        --no-mouse \
        --backtitle "${WIN_TITLE}" \
        --form "Add New Tag" 0 0 0 \
        "tag"   2 4 "" 2 15 90 0 \
        2> "${TMP_FILE}";

    NEW_TAG=$(cat "${TMP_FILE}" | perl -ne 's/^\s*//; s/\s*$//; print lc');

    if [ $(grep -ic "${NEW_TAG}" "${FILE_TAGS}") != 0 ];then
        dialog --msgbox "tag \"${NEW_TAG}\" already exists!" 0 0;
        return 1;
    else
        echo "${NEW_TAG}" >> "${FILE_TAGS}";
        return 0;
    fi;
}

function comments_dialog
{
    TMP_FILE="${TMPF_COMMENTS}";
    ${EDITOR} ${TMP_FILE};

    return $?;
}

# ========================================================================== #
# main #
# ========================================================================== #

form_dialog;
case $? in
    1) clear; exit;;
esac

while [ 1 ]
do
    tags_dialog;
    case $? in
        0) break;;
        1) clear; exit;;
        3) add_new_tag_dialog;
    esac
done

#comments_dialog;

clear;

# compile property file
echo "[tags]" > ${FILE_META};
RES=($(cat "${TMPF_TAGS}"))
for EL in "${RES[@]}"
do
    echo "${TAGS[${EL}]}" >> ${FILE_META};
done

