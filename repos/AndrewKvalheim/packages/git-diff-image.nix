{ fetchFromGitHub
, lib
, makeWrapper
, stdenv
, unstableGitUpdater

  # Dependencies
, bash
, bc
, coreutils
, diffutils
, exiftool
, gnugrep
, gnused
, imagemagick
, xdg-utils
, xdpyinfo
}:

let
  diffImagePath = lib.makeBinPath [
    bash
    bc
    coreutils
    diffutils
    exiftool
    gnugrep
    gnused
    imagemagick
    xdg-utils
    xdpyinfo
  ];
  gitDiffImagePath = lib.makeBinPath [
    bash
    coreutils
    diffutils
    imagemagick
  ];
in
stdenv.mkDerivation {
  pname = "git-diff-image";
  version = "0-unstable-2023-09-04";

  src = fetchFromGitHub {
    owner = "ewanmellor";
    repo = "git-diff-image";
    rev = "f12098b2b9b9f56f205f8e9ca8435796a0fdc1fc";
    hash = "sha256-xfs3848FwQzLdOTAo1vgTJfU71Syk8bHj4VBNAStT0k=";
  };

  buildInputs = [ makeWrapper ];

  postInstall = ''
    install -D -m755 -t $out/bin diff-image git_diff_image
    wrapProgram $out/bin/diff-image --prefix PATH : ${diffImagePath}
    wrapProgram $out/bin/git_diff_image --prefix PATH : ${gitDiffImagePath}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    export PATH=$PATH:$out/bin
    diff-image $src/example-comparison.png $src/example-comparison.png
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Extension to 'git diff' that provides support for diffing images";
    homepage = "https://github.com/ewanmellor/git-diff-image";
    license = lib.licenses.cc0;
    mainProgram = "diff-image";
  };
}
