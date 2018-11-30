{ stdenv, lib, fetchFromGitHub, buildGoPackage }:

with lib;

buildGoPackage rec {
  name = "zsh-history";

  src = fetchFromGitHub {
    owner = "b4b4r07";
    repo = "history";
    rev = "ff09a04a385bd11ab112c9233be9b83fe9f84b33";
    sha256 = "1h1sdpm8fg9nh3k0s26xrkzvjlsjpcwx35db60q32z6g6wvr19sx";
  };

  patches = [ ./0001-Allow-search-filtering-for-command-that-returned-wit.patch ./0002-Fix-filter-with-multiple-options.patch ];

  goDeps = ./deps.nix;
  goPackagePath = "history";

  preConfigure = ''
    # Extract the source
    mkdir -p "$NIX_BUILD_TOP/go/src/github.com/b4b4r07"
    cp -a $NIX_BUILD_TOP/source "$NIX_BUILD_TOP/go/src/github.com/b4b4r07/history"
    export GOPATH=$NIX_BUILD_TOP/go/src/github.com/b4b4r07/history:$GOPATH
  '';

  installPhase = ''
    install -d "$bin/bin"
    install -m 0755 $NIX_BUILD_TOP/go/bin/history "$bin/bin"
    install -d $out/share
    cp -r $NIX_BUILD_TOP/go/src/history/misc/* $out/share
    cp -r $out/share/zsh/completions $out/share/zsh/site-functions
  '';

  meta = {
    description = "A CLI to provide enhanced history for your shell";
    license = licenses.mit;
    homepage = https://github.com/b4b4r07/history;
    platforms = platforms.unix;
    outputsToInstall = [ "out" "bin" ];
  };
}
