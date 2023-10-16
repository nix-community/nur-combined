{ lib
, rustPlatform
, fetchFromGitHub
, rustc
}:

rustPlatform.buildRustPackage {
  pname = "usysconf";
  version = "unstable-2023-09-27";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "usysconf-rs";
    rev = "5e33d474ed04813ccba9a8082e95fd5983a73b45";
    hash = "sha256-4AqMPcsaqS5vulNJzi8hEP41qBl/3/fDkvNpD68yzFI=";
  };

  cargoHash = "sha256-5txMmrHWfssv4qvGI323dY5/H1A59GnDMz9F2Iy/CIo=";

  meta = {
    description = "Usysconf - now with extra rust";
    homepage = "https://github.com/serpent-os/usysconf-rs";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder rustc.version "1.70";
  };
}
