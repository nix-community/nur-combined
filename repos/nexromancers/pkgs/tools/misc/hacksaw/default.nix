{ stdenv, rustPlatform, buildPackages, fetchFromGitHub
, libX11, libXrandr
}:

rustPlatform.buildRustPackage rec {
  pname = "hacksaw-unstable";
  version = "2019-10-16";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "hacksaw";
    rev = "49ed6372fe85f8682d6841da04b38295499445ea";
    sha256 = "08n9y4znakcxa36yqi923s5pf6dbqazn7prmx96npniqippa6rv7";
  };

  cargoSha256 = "0mhk4p0sia6p6ig92wxbnyg25r972k0asps6d34rdahfblplpxsy";

  nativeBuildInputs = [
    buildPackages.pkgconfig
    buildPackages.python3
  ];
  buildInputs = [ libX11 libXrandr ];

  meta = with stdenv.lib; {
    description = "Lets you select areas of your screen (on X11)";
    homepage = https://github.com/neXromancers/hacksaw;
    license = with licenses; mpl20;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
  };
}

