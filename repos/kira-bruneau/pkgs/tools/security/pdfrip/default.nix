{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
}:

rustPlatform.buildRustPackage {
  pname = "pdfrip";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "limitedAtonement";
    repo = "pdfrip";
    rev = "89a8367b003591986ebb4a9385dff074426bde59";
    hash = "sha256-cG3HHELZ0r01cg4CnpMeDJWlJ60+Rz2h4oINcDVuY54=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Multi-threaded PDF password cracking utility equipped with commonly encountered password format builders and dictionary attacks";
    homepage = "https://github.com/mufeedvh/pdfrip";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "pdfrip";
  };
}
