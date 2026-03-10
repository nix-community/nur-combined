{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "dtsfmt";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "mskelton";
    repo = "dtsfmt";
    tag = "v${version}";
    hash = "sha256-2DKfmWnz9Iaxs4VN16BHOzsncEFXaX2mwR2Ta9AyYn0=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-BbX/IEfn5qhyW/IkgARfxD0rTx+hcoq8TmoDmUqclHQ=";

  patches = [
    ./0001-Fix-version.patch
  ];

  meta = {
    description = "Auto formatter for device tree files";
    longDescription = ''
      Auto formatter for device tree files.
    '';
    homepage = "https://github.com/mskelton/dtsfmt";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "dtsfmt";
  };
}
