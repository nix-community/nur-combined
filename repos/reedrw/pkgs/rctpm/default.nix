{ fetchFromGitHub, lib, mkYarnPackage, yarn, makeWrapper }:

mkYarnPackage rec {
  name = "rctpm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "tubbo";
    repo = "rctpm";
    rev = "v${version}";
    sha256 = "sha256-Ivd/5ytcCXRs2fawsc0TRrp/jHS34qwmFPYwYc2JCvk=";
  };

  packageJSON = ./package.json;
  yarnNix = ./yarn-dependencies.nix;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ yarn ];

  buildPhase = ''
    yarn build
  '';

  postInstall = ''
    chmod +x $out/libexec/rctpm/deps/rctpm/dist/src/cli.js

    wrapProgram $out/bin/rctpm \
      --prefix PATH : ${yarn}/bin
  '';

  meta = with lib; {
    description = "OpenRCT2 Plugin Manager";
    homepage = "https://github.com/tubbo/rctpm";
    platforms = platforms.linux;
  };
}
