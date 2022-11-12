{ stdenv, lib
  , writeShellApplication
  , manix
  , ripgrep
  , fzf
}:

writeShellApplication ({
  name = "manix-fzf";
  runtimeInputs = [ manix ripgrep fzf ];
  text = "manix \"\" | rg '^# ' | sed 's/^# \\(.*\\) (.*/\\1/;s/ (.*//;s/^# //' | fzf --preview=\"manix '{}'\" | xargs manix";
})

