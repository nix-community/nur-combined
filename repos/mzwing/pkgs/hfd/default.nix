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
  # fetchgit leaves no .git metadata, so the AUR-style r<count>.<rev>
  # version cannot be reproduced; use the nixpkgs convention instead.
  version = "0-unstable-${source.date}";

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 hfd.sh $out/bin/hfd
    runHook postInstall
  '';

  # The script relies on GNU extensions (find -printf, stat -c%s, sed -i),
  # so the wrapped PATH must provide the GNU toolset for it to work on
  # Darwin. aria2 (default) and wget (fallback) are both included: the
  # script picks one via --tool. Intentionally no git/git-lfs (which the
  # AUR package still depends on): the current script never invokes them.
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

    # hfd --help always exits 1; check its output instead.
    help_output="$($out/bin/hfd --help 2>&1 || :)"
    grep -F 'hfd <REPO_ID>' <<<"$help_output"

    runHook postInstallCheck
  '';

  meta = {
    description = "CLI tool for downloading Hugging Face models and datasets with aria2/wget";
    homepage = "https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f";
    # The upstream gist carries no license file (the AUR package also
    # marks it as "unknown"), so meta.license is left unset.
    mainProgram = "hfd";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = lib.platforms.all;
  };
}
