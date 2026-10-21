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
    version = "0.1.1";
    cliHash = "sha256-M8Q+ovgDIVZi9aMf354byoarZ8rE8jmFZcK6EuF8IYU=";
    desktopHash = "sha256-+KtS/hDvPLhyoIPQOP0SDdHsW0mP71aNBLKLenLGDDc=";
  };

  nightly = mkSources {
    version = "0.1.1-nightly.20261018.3335";
    cliHash = "sha256-cWCwYX98oBi3e6ScJDXTFiDQpjot0SQ4CjF7xxQP2gI=";
    desktopHash = "sha256-TBKIdwcCDKwkScUEMzMZKfdcgyiPSXl+3bTHHqIYCE8=";
  };
}
