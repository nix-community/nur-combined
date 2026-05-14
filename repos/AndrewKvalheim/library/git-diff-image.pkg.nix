{ fetchFromGitHub
, lib
, makeWrapper
, stdenv
, unstableGitUpdater

  # Dependencies
, bash
, bc
, diffutils
, exiftool
, gnugrep
, gnused
, imagemagick
, uutils-coreutils
, xdg-utils
, xdpyinfo
}:

let
  inherit (lib) licenses makeBinPath;

  uutils-coreutils' = uutils-coreutils.override { prefix = null; };

  dependencies = {
    diff-image = [
      bash
      bc
      diffutils
      exiftool
      gnugrep
      gnused
      imagemagick
      uutils-coreutils'
      xdg-utils
      xdpyinfo
    ];

    git_diff_image = [
      bash
      diffutils
      imagemagick
      uutils-coreutils'
    ];
  };
in
stdenv.mkDerivation {
  pname = "git-diff-image";
  version = "0-unstable-2023-09-04";
  meta = {
    description = "Extension to 'git diff' that provides support for diffing images";
    homepage = "https://github.com/ewanmellor/git-diff-image";
    license = licenses.cc0;
    mainProgram = "diff-image";
  };

  passthru.updateScript = unstableGitUpdater { };

  src = fetchFromGitHub {
    owner = "ewanmellor";
    repo = "git-diff-image";
    rev = "f12098b2b9b9f56f205f8e9ca8435796a0fdc1fc";
    hash = "sha256-xfs3848FwQzLdOTAo1vgTJfU71Syk8bHj4VBNAStT0k=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    install -D --mode '755' --target-directory "$out/bin" \
      'diff-image' \
      'git_diff_image'
    wrapProgram "$out/bin/diff-image" \
      --prefix PATH : ${makeBinPath dependencies.diff-image}
    wrapProgram "$out/bin/git_diff_image" \
      --prefix PATH : ${makeBinPath dependencies.git_diff_image}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    export PATH=$PATH:$out/bin
    diff-image $src/example-comparison.png $src/example-comparison.png
  '';
}
