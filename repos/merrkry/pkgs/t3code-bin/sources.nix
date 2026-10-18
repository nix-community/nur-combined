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
    version = "0.1.1-nightly.20261018.3285";
    cliHash = "sha256-IZ/E07er4QMRyecbE8YtgeJxebmfTt8gJwoyqASoRmA=";
    desktopHash = "sha256-6tJjAtu3o2C/t42N75+MlU96Xsu3FQo5z4qCVoBUbSk=";
  };
}
