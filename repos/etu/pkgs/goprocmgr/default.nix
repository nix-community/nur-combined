{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pandoc,
  installShellFiles,
  ...
}: let
  pname = "goprocmgr";
  version = "1.2.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "TaserudConsulting";
      repo = "goprocmgr";
      rev = version;
      sha256 = "sha256-hyJ3aOKKPvnDiNaHv2MghK/MURco2yUtv069VavJpYE=";
    };

    vendorHash = "sha256-aA+FeMBLhvh4pg3W4eHEfBtOf5oUnDDUkKnHEQA/+vI=";

    nativeBuildInputs = [
      pandoc
      installShellFiles
    ];

    prePatch = ''
      substituteInPlace CLI.md main.go --replace-fail "%undefined-version%" ${version}
    '';

    postBuild = ''
      pandoc -s -t man CLI.md -o goprocmgr.1
    '';

    postInstall = ''
      install -Dm644 goprocmgr.1 $out/share/man/man1/goprocmgr.1
      installShellCompletion --cmd goprocmgr contrib/completions/goprocmgr.{fish,bash}
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
