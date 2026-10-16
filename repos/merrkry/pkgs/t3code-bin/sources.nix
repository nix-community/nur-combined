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
    version = "0.1.0";
    cliHash = "sha256-93A/8buPYkNYAFizzPLAKrti66S5keJrux2iL0tW2bE=";
    desktopHash = "sha256-442cX7UTsezgpwi5BtM4O1tH7RmVdbOaMeQauINOt0Q=";
  };

  nightly = mkSources {
    version = "0.0.46-nightly.20261015.3176";
    cliHash = "sha256-2IyzlQwtM46vfnXiLJvXwxoQqnSLJuJr76exwb0uEak=";
    desktopHash = "sha256-FVtah+pPR5rSaUzaAUGjX+MYzaAEfhAaUBX/sOO4TI8=";
  };
}
