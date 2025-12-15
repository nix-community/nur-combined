{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  curl,
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

      meta = {
        maintainers = with lib.maintainers; [ xddxdd ];
        description = "Asterisk ${name} Codec by Digium";
        homepage = "https://downloads.digium.com/pub/telephony/codec_${name}/";
        license = lib.licenses.unfree;
        platforms = [
          "x86_64-linux"
          "i686-linux"
        ];
      };
    };

  mkAsteriskVersion =
    asterisk_version: v:
    lib.nameValuePair (builtins.replaceStrings [ "." ] [ "_" ] asterisk_version) (
      lib.recurseIntoAttrs (
        lib.filterAttrs (n: v: v != null) (
          lib.mapAttrs (
            name: value:
            if stdenv.isx86_64 && (value."64" or "unset") != "unset" then
              mkLibrary asterisk_version name "64" value."64"
            else if stdenv.isi686 && (value."32" or "unset") != "unset" then
              mkLibrary asterisk_version name "32" value."32"
            else
              null
          ) v
        )
      )
    );
in
lib.recurseIntoAttrs (lib.mapAttrs' mkAsteriskVersion (lib.importJSON ./sources.json))
