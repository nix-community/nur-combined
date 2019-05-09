{ stdenv, rustPlatform, buildPackages, fetchFromGitHub
, libX11, libXrandr
}:

rustPlatform.buildRustPackage rec {
  pname = "hacksaw-unstable";
  version = "2019-02-20";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "hacksaw";
    rev = "0bee951e22240dc87b27dacc944653c9a741a1d0";
    sha256 = "0z4pw8l895sc2cg688l9nwnl0mpabjc7fc5y3mfa0xjg4wyh5dd3";
  };

  cargoSha256 = "09cc9mvf99p8nr6wh3g9a6xxb8q1z51284knlvamxk18sdc7s0h0";

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

