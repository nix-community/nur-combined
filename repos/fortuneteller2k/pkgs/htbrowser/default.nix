{ lib, mkYarnPackage, fetchFromGitHub, makeWrapper, electron, libX11, libXScrnSaver, node-pre-gyp, python3 }:

mkYarnPackage rec {
  pname = "htBrowser";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "mTvare6";
    repo = pname;
    rev = "937a4074a48c50e3b8c37bb5f3a4b9cdd69a400f";
    sha256 = "sha256-dozV6JbpGRgayfC44N6NUxftWfKQCPq3wnUig048Qj8=";
  };

  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;
  yarnFlags = [ "--production" "--offline" ];

  nativeBuildInputs = [ makeWrapper node-pre-gyp python3 ];

  buildInputs = [ libX11 libXScrnSaver ];

  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/htBrowser \
      --add-flags $out/libexec/htBrowser/node_modules/htBrowser/main.js
  '';

  meta = with lib; {
    homepage = "https://github.com/mTvare6/htBrowser";
    description = "A hotkey browser made for developers to have easy doc access on any screen";
    maintainers = with maintainers; [ fortuneteller2k ];
    platforms = platforms.unix;
    license = licenses.mpl20;
  };
}
