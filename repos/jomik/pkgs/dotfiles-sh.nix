{ lib, stdenv, fetchFromGitHub, makeWrapper, git }:

stdenv.mkDerivation rec {
  name = "dotfiles-sh-${version}";
  version ="20181024";

  src = fetchFromGitHub {
    owner = "eli-schwartz";
    repo = "dotfiles.sh";
    rev = "07c2a57a72ca2bed5d3739b645fa3166b072b0dd";
    sha256 = "18xlk6cgy7p8ikjqr5iypsf665lrzxfwskbd8kh0v47zrpi4ri9y";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    install -m 755 -Dt $out/bin $src/dotfiles
  '';

  postFixup = ''
    wrapProgram $out/bin/dotfiles \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  meta = {
    homepage = https://github.com/eli-schwarts/dotfiles.sh;
    description = "Dotfiles made easy";
    longDescription = ''
      A simple wrapper around git that runs all git commands with a custom $GIT_DIR, allowing metadata to be stored separate from the files. gitignore and gitattributes files can be easily hidden through the use of sparse checkout. A handful of administrative commands are also provided to bootstrap the repository.
    '';
  };
}

