{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pandoc,
  ...
}: let
  pname = "goprocmgr";
  version = "1.1.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "TaserudConsulting";
      repo = "goprocmgr";
      rev = version;
      sha256 = "sha256-sByMfayFhhnGnhMW25azakaBjjYQFFD3lxgbDO6fWto=";
    };

    vendorHash = "sha256-aA+FeMBLhvh4pg3W4eHEfBtOf5oUnDDUkKnHEQA/+vI=";

    nativeBuildInputs = [
      pandoc
    ];

    prePatch = ''
      substituteInPlace CLI.md main.go --replace-fail "%undefined-version%" ${version}
    '';

    postBuild = ''
      pandoc -s -t man CLI.md -o goprocmgr.1
    '';

    postInstall = ''
      install -Dm644 goprocmgr.1 $out/share/man/man1/goprocmgr.1
    '';

    meta = with lib; {
      description = "A simple process manager for Go";
      homepage = "https://github.com/TaserudConsulting/${pname}";
      changelog = "https://github.com/TaserudConsulting/${pname}/releases/tag/${version}";
      license = licenses.isc;
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
