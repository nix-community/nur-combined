{ fetchurl }:

let
  mkSources =
    {
      version,
      cliHash,
      desktopHash,
    }:
    {
      cli = {
        inherit version;
        src = fetchurl {
          url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/t3-${version}-linux-x64.tar.gz";
          hash = cliHash;
        };
      };

      desktop = {
        inherit version;
        src = fetchurl {
          url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
          hash = desktopHash;
        };
      };
    };
in
{
  stable = mkSources {
    version = "0.0.45";
    cliHash = "sha256-EFBa50vGpDz6sP3gvwag4NaGL3QDBZG+mUpkDUig1r0=";
    desktopHash = "sha256-q3sKhtHqZXzMFitgt3LGH3C8fIueJZtGk51Tuzj6oCo=";
  };

  nightly = mkSources {
    version = "0.0.46-nightly.20261006.2752";
    cliHash = "sha256-PRDJ+3ygQmR/s8B6CfZGWwvHzsGPEcDDSPW4w6dWp0c=";
    desktopHash = "sha256-7bX9gGXWWB7fPc/Q3ecU/tDOxwQP+wykxWAkbSduV6A=";
  };
}
