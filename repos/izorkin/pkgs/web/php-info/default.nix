{ stdenv }:
let
  source = builtins.toFile "php-info.php" ''
    <?php
      phpinfo();
    ?>
  '';
in

stdenv.mkDerivation rec {
  name = "php-info";
  phases = [ "installPhase" ];
  installPhase = ''
    install -Dm0444 ${source} $out/info.php
  '';
}

