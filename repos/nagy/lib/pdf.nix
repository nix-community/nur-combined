{
  pkgs,
  lib ? pkgs.lib,
}:

{
  mkPdfEncrypted =
    {
      file,
      password,
      pdftk ? pkgs.pdftk,
    }:
    pkgs.runCommandLocal "output.pdf"
      {
        src = lib.cleanSource file;
        nativeBuildInputs = [ pdftk ];
        inherit file password;
      }
      ''
        pdftk "$src" output output.pdf user_pw PROMPT <<< "$password"
        install -Dm644 -t "$out" output.pdf
      '';
}
