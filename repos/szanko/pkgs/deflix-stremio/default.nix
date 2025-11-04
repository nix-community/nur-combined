{ lib
, stdenvNoCC
, fetchzip
}:

let
  sys = stdenvNoCC.hostPlatform.system;

  assetFor = system:
    if system == "x86_64-linux" then {
      url  = "https://github.com/doingodswork/deflix-stremio/releases/download/v0.11.1/deflix-stremio_v0.11.1_Linux_x64.tar.gz";
      hash = "sha256-gzn6gfp1Z/4PdRV66124rQL13pHBys5ac+RRXJhwQHs=";
      exe  = "deflix-stremio";
    } else if system == "x86_64-darwin" then {
      url  = "https://github.com/doingodswork/deflix-stremio/releases/download/v0.11.1/deflix-stremio_v0.11.1_macOS_x64.tar.gz";
      hash = "sha256-OjYgCGIz+TxRl5Q+QyNO8RBHZoci7WCuaPdbadTsYGs=";
      exe  = "deflix-stremio";
    } else if system == "x86_64-windows" then {
      url  = "https://github.com/doingodswork/deflix-stremio/releases/download/v0.11.1/deflix-stremio_v0.11.1_Windows_x64.zip";
      hash = "sha256-A8iPBQDFD9svxr1EqvblJOjmLMI0wuJr4rI0sNlq8Co=";
      exe  = "deflix-stremio.exe";
    } else
      throw "deflix-stremio: no prebuilt asset for system '${system}' (supported: x86_64-linux, x86_64-darwin, x86_64-windows)";

  a = assetFor sys;
in
  stdenvNoCC.mkDerivation {
    pname = "deflix-stremio";
    version = "0.11.1";

    src = fetchzip {
      url       = a.url;
      hash      = a.hash;
      stripRoot = false; 
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"

      exe="$(find "$src" -maxdepth 2 -type f -name '${a.exe}' -print -quit)"
      if [ -z "$exe" ]; then
      echo "ERROR: could not find ${a.exe} in $src" >&2
      echo "Contents:" >&2
      find "$src" -maxdepth 2 -type f >&2
      exit 1
      fi

      install -Dm0755 "$exe" "$out/bin/${a.exe}"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Deflix addon for Stremio (prebuilt binary)";
      homepage    = "https://github.com/doingodswork/deflix-stremio";
      license     = licenses.agpl3Only;
      maintainers =
        let m = lib.maintainers or {};
        in lib.optionals (m ? szanko) [ m.szanko ];
      mainProgram = "deflix-stremio";
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
      platforms   = [ "x86_64-linux" "x86_64-darwin" "x86_64-windows" ];
    };
  }

