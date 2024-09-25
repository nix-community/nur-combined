{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  curl,
  mergePkgs,
  ...
}:
let
  mkLibrary =
    asterisk_version: name: _bits: value:
    stdenv.mkDerivation rec {
      pname = "asterisk-${asterisk_version}-codec-${name}";
      inherit (value) version;
      src = fetchurl {
        inherit (value) url;
        sha256 = value.hash;
      };

      nativeBuildInputs = [ autoPatchelfHook ];
      buildInputs = [ curl ];
      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp * $out/

        runHook postInstall
      '';

      meta = with lib; {
        maintainers = with lib.maintainers; [ xddxdd ];
        description = "Asterisk ${asterisk_version} ${name} Codec by Digium";
        homepage = "https://downloads.digium.com/pub/telephony/codec_${name}/";
        license = licenses.unfree;
        platforms = [
          "x86_64-linux"
          "i686-linux"
        ];
      };
    };

  mkAsteriskVersion =
    asterisk_version: v:
    mergePkgs (
      lib.mapAttrs (
        name: value:
        if stdenv.isx86_64 then
          mkLibrary asterisk_version name "64" value."64"
        else
          mkLibrary asterisk_version name "32" value."32"
      ) v
    );
in
lib.mapAttrs mkAsteriskVersion (lib.importJSON ./sources.json)
