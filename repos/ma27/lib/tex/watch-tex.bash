#! @bash@

FILE=${1:-}
BIBTEX_FILE=${2:-}
if [ -z "$FILE" ]; then
  echo -e "\e[31mNo file to watch was specified. Aborting...\e[0m"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo -e "\e[31mArgument \`$FILE' is not a valid file. Aborting...\e[0m"
  exit 1
fi

if [ ! -z "$BIBTEX_FILE" ]; then
  if [ ! -f "$FILE" ]; then
    echo -e "\e[31mLiteratur \`$BIBTEX_FILE' is not a valid file. Aborting...\e[0m"
  fi
fi

rebuild_tex() {
  error=${1:-}
  success=${2:-}
  chsum_tex=$(md5sum $FILE)
  pdflatex -interaction=nonstopmode $FILE 2>&1 >/dev/null
  if [ $? -eq 0 ]; then
    if [ ! -z "$success" ]; then
      echo -e "\e[2m  $success\e[0m"
    fi
  else
    if [ ! -z "$error" ]; then
      echo -e "\e[31m  $error\e[0m"
    fi
    exit 1
  fi
}

echo -e "\e[32mWaiting for changes in \`$FILE'...\e[0m\n"

chsum_tex=
compare_tex=
chsum_bib=
compare_bib=

while [ true ];
do
  compare_tex=$(md5sum $FILE)
  compare_bib=$(md5sum $BIBTEX_FILE)
  exit=0
  if [ "$chsum_tex" != "$compare_tex" -o "$compare_bib" != "$chsum_bib" ]; then
    echo -e "* \e[32mChange in \`$FILE' detected at $(date '+%H:%m:%S')\e[0m"

    LOG=$(echo $FILE | sed -e 's,\.tex,\.log,')
    rebuild_tex "Build returned a non-zero exit status! Please review $LOG." \
      "Build successful, continuing..."
    exit=$?
  fi

  if [ $exit -eq 0 -a ! -z "$BIBTEX_FILE" -a "$chsum_bib" != "$compare_bib" ]; then
    chsum_bib=$(md5sum $BIBTEX_FILE)
    bibtex $(echo $FILE | sed -e 's,\.tex$,\.aux,') >/dev/null
    if [ $? -eq 0 ]; then
      echo -e "\e[2m  Bibtex build of \`$BIBTEX_FILE' successful, rebuilding \`$FILE'...\e[0m"
      rebuild_tex
    else
      echo -e "\e[31m  Bibtex build of \`$BIBTEX_FILE' failed!\e[0m"
    fi
  fi

  sleep 3
done
