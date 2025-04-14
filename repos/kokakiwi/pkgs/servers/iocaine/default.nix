{
  lib,
  fetchFromGitea,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "iocaine";
  version = "2.0.0";

  src = fetchFromGitea {
    domain = "git.madhouse-project.org";
    owner = "iocaine";
    repo = "iocaine";
    tag = "iocaine-${version}";
    hash = "sha256-VYTn/OcY+5bQ22k2k7y36udoOOm65r8jeipTwldcEu8=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-FKSDT8B70BRhINTIwjPga9PP1lPedabbLs+daIviQzg=";

  meta = with lib; {
    description = "The deadliest poison known to AI";
    license = licenses.mit;
    platforms = platforms.linux;
    homepage = "https://iocaine.madhouse-project.org/";
    mainProgram = "iocaine";
  };
}
