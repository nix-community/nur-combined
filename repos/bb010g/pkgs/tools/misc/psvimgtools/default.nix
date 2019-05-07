{ stdenv, buildPackages, fetchFromGitHub
, libgcrypt, zlib
}:

let
  inherit (stdenv.lib) chooseDevOutputs;
in stdenv.mkDerivation rec {
  pname = "psvimgtools";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "yifanlu";
    repo = "psvimgtools";
    # rev = "v${version}";
    rev = "v0.1";
    sha256 = "119bka85cl8kkl18pvp0r5mywwsfnkppr89936abx5pmvk7sv869";
  };

  nativeBuildInputs = [
    buildPackages.cmake
  ];
  buildInputs = chooseDevOutputs [
    libgcrypt
    zlib
  ];

  meta = with stdenv.lib; {
    description = "Decrypt Vita CMA backups";
    longDescription = ''
      This is a set of tools that let you decrypt, extract, and repack Vita
      CMA backup images. To use this you need your backup key which is tied to
      your PSN AID.
    '';
    homepage = https://github.com/yifanlu/psvimgtools;
    license = with licenses; mit;
    maintainers = with maintainers; [ bb010g ];
    platforms = with platforms; all;
  };
}
