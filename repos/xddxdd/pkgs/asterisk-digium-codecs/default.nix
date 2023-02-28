{
  stdenv,
  lib,
  recurseIntoAttrs,
  fetchurl,
  autoPatchelfHook,
  asterisk,
  curl,
  ...
} @ args: let
  mkLibrary = asterisk_version: name: bits: value:
    stdenv.mkDerivation rec {
      pname = "asterisk-${asterisk_version}-codec-${name}";
      version = value.version;
      src = fetchurl {
        url = value.url;
        sha256 = value.hash;
      };

      nativeBuildInputs = [autoPatchelfHook];
      buildInputs = [curl];
      installPhase = ''
        mkdir -p $out
        cp * $out/
      '';

      meta = with lib; {
        description = "Asterisk ${asterisk_version} ${name} Codec by Digium";
        homepage = "https://downloads.digium.com/pub/telephony/codec_${name}/";
        license = licenses.unfree;
        platforms =
          if bits == "64"
          then ["x86_64-linux"]
          else if bits == "32"
          then ["i686-linux"]
          else throw "Unsupported architecture";
      };
    };

  mkAsteriskVersion = asterisk_version: v:
    recurseIntoAttrs (lib.mapAttrs
      (name: value:
        if stdenv.isx86_64
        then mkLibrary asterisk_version name "64" value."64"
        else if stdenv.isi686
        then mkLibrary asterisk_version name "32" value."32"
        else throw "Unsupported architecture")
      v);
in
  lib.mapAttrs mkAsteriskVersion (lib.importJSON ./sources.json)
