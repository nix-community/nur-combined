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
    version = "0.0.46-nightly.20261013.3080";
    cliHash = "sha256-099oL/2voB7PGhJos4C13dKEIb75QEZ0puhu2F9FT4E=";
    desktopHash = "sha256-GOhRzvoerNl/VtCCqn9NGKP584hTQr8bYhl9gKOduwQ=";
  };
}
