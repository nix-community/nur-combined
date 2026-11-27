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
    version = "0.1.13";
    desktopFile = "T3-Code-x86_64.AppImage";
    cliHash = "sha256-ZOD4RG0/YYsVfU5aCmgIqzyL8aGz5E6rMQDlVL4F5dc=";
    desktopHash = "sha256-2sG76ek8Gl+wlCMyvvqZhZf2oIYjKod2bvXYI1pE9W0=";
  };

  nightly = mkSources {
    version = "0.1.1-nightly.20261018.3335";
    cliHash = "sha256-cWCwYX98oBi3e6ScJDXTFiDQpjot0SQ4CjF7xxQP2gI=";
    desktopHash = "sha256-TBKIdwcCDKwkScUEMzMZKfdcgyiPSXl+3bTHHqIYCE8=";
  };
}
