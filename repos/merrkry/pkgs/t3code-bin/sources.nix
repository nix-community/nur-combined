{ fetchurl }:

let
  mkSources =
    {
      version,
      cliHash,
      desktopHash,
      desktopFile ? "T3-Code-${version}-x86_64.AppImage",
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
          url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/${desktopFile}";
          hash = desktopHash;
        };
      };
    };
in
{
  stable = mkSources {
    version = "0.1.12";
    desktopFile = "T3-Code-x86_64.AppImage";
    cliHash = "sha256-m6PbRuNVT7mXD9Xt6egjwvbW9nY/QDQL1MjvawlQHFQ=";
    desktopHash = "sha256-ZrkVUVcd9tKbVctZApXt9BHP+WyVqP6z9Bw8pZXXIuI=";
  };

  nightly = mkSources {
    version = "0.1.1-nightly.20261018.3335";
    cliHash = "sha256-cWCwYX98oBi3e6ScJDXTFiDQpjot0SQ4CjF7xxQP2gI=";
    desktopHash = "sha256-TBKIdwcCDKwkScUEMzMZKfdcgyiPSXl+3bTHHqIYCE8=";
  };
}
