{
  fetchFromGitHub,
  lib,
}: let
  source = builtins.fromJSON (builtins.readFile ./didoesdigital-dictionary.json);
in
  (fetchFromGitHub {
    owner = "didoesdigital";
    repo = "steno-dictionaries";
    inherit (source) rev sha256;
  })
  .overrideAttrs (_: {
    meta.license = lib.licenses.gpl2;
    passthru.updateScript = [../scripts/update-git.sh "https://github.com/didoesdigital/steno-dictionaries" "plover/didoesdigital-dictionary.json"];
  })
