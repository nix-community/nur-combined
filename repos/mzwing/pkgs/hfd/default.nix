{
  lib,
  stdenvNoCC,
  source,
  makeWrapper,
  aria2,
  coreutils,
  curl,
  findutils,
  gawk,
  gnugrep,
  gnused,
  jq,
  wget,
}:
stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  # Use an unstable version because fetchgit omits revision metadata.
  version = "0-unstable-${source.date}";

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 hfd.sh $out/bin/hfd
    runHook postInstall
  '';

  # Provide GNU tools plus the aria2 and wget download backends on every platform.
  postFixup = ''
    wrapProgram $out/bin/hfd \
      --prefix PATH : ${
      lib.makeBinPath [
        aria2
        coreutils
        curl
        findutils
        gawk
        gnugrep
        gnused
        jq
        wget
      ]
    }
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # `hfd --help` exits 1, so inspect its output.
    help_output="$($out/bin/hfd --help 2>&1 || :)"
    grep -F 'hfd <REPO_ID>' <<<"$help_output"

    runHook postInstallCheck
  '';

  meta = {
    description = "CLI tool for downloading Hugging Face models and datasets with aria2/wget";
    homepage = "https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f";
    # Upstream provides no license file.
    mainProgram = "hfd";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = lib.platforms.all;
  };
}
