#vim:ft=bash
$DRY_RUN_CMD mkdir -p ~/.config/BetterDiscord/data/stable
if [ -L ~/.config/BetterDiscord/data/stable/custom.css ]; then
    $DRY_RUN_CMD mv ~/.config/BetterDiscord/data/stable/custom.css ~/.config/BetterDiscord/data/stable/custom.css.old
fi
if [ -v DRY_RUN ]; then
  echo "cat \"$BETTERDISCORD_CSS_TEMPLATE\" | colorpipe > ~/.config/BetterDiscord/data/stable/custom.css"
else
  cat "$BETTERDISCORD_CSS_TEMPLATE" | colorpipe > ~/.config/BetterDiscord/data/stable/custom.css
fi

