{
  lib,
  fetchFromGitea,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "iocaine";
  version = "2.2.0";

  src = fetchFromGitea {
    domain = "git.madhouse-project.org";
    owner = "iocaine";
    repo = "iocaine";
    tag = "iocaine-${version}";
    hash = "sha256-mRuWesW/l1kWYay3RPwDfcHbYw1FbU2pwtKJFSeuzIQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-zCWvgHmpb/P2vsXQk98i/PJIIZubstbbdZx6080f0fk=";

  meta = with lib; {
    description = "The deadliest poison known to AI";
    license = licenses.mit;
    platforms = platforms.linux;
    homepage = "https://iocaine.madhouse-project.org/";
    mainProgram = "iocaine";
  };
}
