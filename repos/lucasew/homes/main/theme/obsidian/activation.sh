#vim:ft=bash
$DRY_RUN_CMD mkdir -p ~/WORKSPACE/ZETTEL/obsidian/content/.obsidian/themes/
if [ -L  ~/WORKSPACE/ZETTEL/obsidian/content/.obsidian/themes/base16.css ]; then
    $DRY_RUN_CMD mv ~/WORKSPACE/ZETTEL/obsidian/content/.obsidian/themes/base16.css ~/WORKSPACE/ZETTEL/obsidian/content/.obsidian/themes/base16.css.old
fi
if [ -v DRY_RUN ]; then
  echo "cat \"$OBSIDIAN_CSS_TEMPLATE\" | colorpipe > ~/WORKSPACE/ZETTEL/obsidian/content/.obsidian/themes/base16.css"
else
  cat "$OBSIDIAN_CSS_TEMPLATE" | colorpipe > ~/WORKSPACE/ZETTEL/obsidian/content/.obsidian/themes/base16.css
fi

