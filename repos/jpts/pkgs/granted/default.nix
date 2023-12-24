{ bash
, buildGoModule
, fetchFromGitHub
, withFish ? false
, fish
, lib
, makeWrapper
, installShellFiles
, stdenv
, xdg-utils ? stdenv.isLinux
,
}:
buildGoModule rec {
  pname = "granted";
  version = "0.20.4";

  src = fetchFromGitHub {
    owner = "common-fate";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-U8j1IxeBcm9aEJ8LtIxNPdz5mqkSGQ6Ldn7F3HomvGE=";
  };

  vendorHash = "sha256-HRZKvs3q79Q94TYvdIx2NQU49MmS2PD1lRndcV0Ys/o=";

  nativeBuildInputs = [ makeWrapper installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/common-fate/granted/internal/build.Version=v${version}"
    "-X github.com/common-fate/granted/internal/build.Commit=${src.rev}"
    "-X github.com/common-fate/granted/internal/build.Date=1970-01-01-00:00:01"
    "-X github.com/common-fate/granted/internal/build.BuiltBy=Nix"
    "-X github.com/common-fate/granted/internal/build.ConfigFolderName=.granted"
  ];

  subPackages = [
    "cmd/granted"
  ];

  postInstall =
    ''
      ln -s $out/bin/granted $out/bin/assumego

      # Install shell script
      patchShebangs scripts
      substituteInPlace scripts/assume \
        --replace assumego $out/bin/assumego
      install -Dm755 scripts/assume $out/bin/assume

      # Generate completions
      export HOME=/tmp
      mkdir -p ~/.granted
      $out/bin/granted completion -s zsh
      installShellCompletion --cmd granted --zsh ~/.granted/zsh_autocomplete/granted/_granted
      installShellCompletion --cmd assume --zsh ~/.granted/zsh_autocomplete/assume/_assume
    ''
    + lib.optionalString stdenv.isLinux ''
      wrapProgram $out/bin/assume \
        --suffix-each PATH : "${lib.makeBinPath [xdg-utils]} $out/bin"
    ''
    + lib.optionalString withFish ''
      # Install fish script
      install -Dm755 $src/scripts/assume.fish $out/share/assume.fish
      substituteInPlace $out/share/assume.fish \
        --replace /bin/fish ${fish}/bin/fish
    '';

  meta = with lib; {
    description = "The easiest way to access your cloud.";
    homepage = "https://github.com/common-fate/granted";
    changelog = "https://github.com/common-fate/granted/releases/tag/${version}";
    license = licenses.mit;
    maintainers = [ maintainers.ivankovnatsky ];
  };
}
