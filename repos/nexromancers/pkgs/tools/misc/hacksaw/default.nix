{ stdenv, rustPlatform, buildPackages, fetchFromGitHub
, libX11, libXrandr
}:

rustPlatform.buildRustPackage rec {
  pname = "hacksaw-unstable";
  version = "2019-10-08";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "hacksaw";
    rev = "fc2549f34943b2e8cd76137d1ab01b2569d7bc91";
    sha256 = "03knw1247q8xqin17qswf681kmsdg4lalm0hhrrm5lfy5wdn5iq0";
  };

  cargoSha256 = "1jmlmz4b1x1b914c0b3g9i7qjjlyi8disb4gj58bx5ykxr2g28kc";

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

