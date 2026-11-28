{
  pkgs,
  stdenv,
  fetchFromGitHub,
  writeTextFile,
  lib,
}:

let
  polyml = pkgs.polyml.overrideAttrs (
    _:
    {
      pname = "polyml-for-isabelle";
      version = "2026";
      src = fetchFromGitHub {
        owner = "polyml";
        repo = "polyml";
        rev = "ccd3e3717f7238b9b5d295fea4b5426182dfc0b6";
        hash = "sha256-wYW8aSvXzhW3hCDeorkD59j+1S6smzsFXHuPYeqo7z8=";
      };
      configureFlags = [
        "--enable-intinf-as-int"
        "--with-gmp"
        "--disable-shared"
      ];
      buildFlags = [ "compiler" ];
      postInstall = ''
        echo "ba433f9b-1286-450a-afb6-53f49be54d33" > $out/bin/poly.uuid
      '';
      passthru.settings = writeTextFile {
        name = "polyml-settings";
        text = ''
          ML_SYSTEM_64=${lib.boolToString stdenv.hostPlatform.is64bit}
          ML_SYSTEM=${polyml.name}
          ML_PLATFORM=${stdenv.hostPlatform.system}
          ML_OPTIONS="--minheap 1000"
          POLYML_HOME=${polyml}
          ML_SOURCES="${polyml}/src"
        '';
        destination = "/etc/settings";
      };
    }
    // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      # Poly/ML's upstream tests open loopback and Unix-domain sockets.
      __noChroot = true;
    }
  );
in
polyml
