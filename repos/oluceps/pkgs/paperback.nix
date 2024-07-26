{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "paperback";
  version = "unstable-2024-07-24";

  src = fetchFromGitHub {
    owner = "cyphar";
    repo = "paperback";
    rev = "af9a2886f61312abfb7b4f914e076006dc4178c3";
    hash = "sha256-ozCVR11vQEXZdXggxhvaGUCPt/ib0t6IniDrqc5BQE4=";
  };

  cargoLock = {
    lockFile = ./lock/paperback.lock;
    outputHashes = {
      "unsigned-varint-0.7.1" = "sha256-vAInaseEmzXS3sPChBBIZ24O8mvceLECMlk8sLwA3Zo=";
    };
  };

  meta = with lib; {
    description = "Paper backup generator suitable for long-term storage";
    homepage = "https://github.com/cyphar/paperback";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ oluceps ];
    mainProgram = "paperback";
  };
}
