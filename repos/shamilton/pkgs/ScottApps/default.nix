{ lib
, stdenv
, fetchFromGitHub
, SDL
, SDL_image
, pkg-config
# , nix-gitignore
}:

stdenv.mkDerivation rec {
  pname = "ScottApps";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Scott-Apps";
    rev = "745db42791d39458de46711d230aa2c5d90cf8a8";
    sha256 = "sha256-TsFhZeiXa8RZZhT9uiwY8H+YzLe1DPsYIkLm4XitBCw=";
  };
  # src = nix-gitignore.gitignoreSource [ ] ~/GIT/Scott-Apps;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ SDL SDL_image ];

  makeFlags = [
    "PREFIX=$(out)"
    "DATADIR=$(out)/share"
    "ASSETDIR=$(out)/share/assets"
  ];

  postInstall = ''
    install -Dm 644 assets/balle.bmp "$out/share/assets/balle.bmp"
    install -Dm 644 assets/Racket.bmp "$out/share/assets/Racket.bmp"
    install -Dm 644 assets/Perdu.bmp "$out/share/assets/Perdu.bmp"
    install -Dm 644 assets/imgMenu.bmp "$out/share/assets/imgMenu.bmp"

    ln -s "$out/bin/ScottsPong" "$out/bin/${pname}"
  '';

  ## FOR DEBUGGING
  # NIX_CFLAGS_COMPILE = "-g -O0";
  # hardeningDisable = [ "all" ]; 
  # dontStrip = true;

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
