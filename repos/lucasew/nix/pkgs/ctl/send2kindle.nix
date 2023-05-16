{ lib, pkgs, ... }:
{
  subcommands.send2kindle = {
    allowExtraArguments = true;
    description = "Send documents to kindle";
    flags = [
      { description = "Convert documents before sending"; keywords = [ "-c" ]; variable = "KINDLE_CONVERT_EBOOK"; validator = "bool"; }
    ];
    action.bash = ''
      ARGS=()
      ARGS+=(dotenv @/home/lucasew/.dotfiles/secrets/p2k.env -- send2kindle)
      if [ -v KINDLE_CONVERT_EBOOK ]; then
        echo "Conversion before sending enabled"
        ARGS+=(-c)
      fi
      for line in "$@"; do
        echo $line
      done
      ${"$"}{ARGS[@]} "$@"
    '';

  };
}
