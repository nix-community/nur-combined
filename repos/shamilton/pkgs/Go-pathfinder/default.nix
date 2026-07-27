{ lib
, fetchFromGitHub
, buildGoApplication
# , nix-gitignore
, pkg-config
, SDL2
, SDL2_ttf
, libX11
}:
buildGoApplication rec {
  pname = "Go-pathfinder";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = pname;
    rev = "e913e2c42940833829279569d2c908d9c34b9c1c";
    sha256 = "sha256-0uE2cpmnU5vxkMKeN0TCSe652eGNja4mkbIz6gm1ztk=";
  };
  # src = nix-gitignore.gitignoreSource [ ] ~/GIT/Go-pathfinder;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ SDL2 SDL2_ttf libX11 ];
  ldflags = [ "-X 'main.assetsDir=${placeholder "out"}/share/assets/'" ];

  postInstall = ''
    install -Dm 644 F25_Bank_Printer.ttf "$out/share/assets/F25_Bank_Printer.ttf"
  '';

  modules = ./gomod2nix.toml;

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
