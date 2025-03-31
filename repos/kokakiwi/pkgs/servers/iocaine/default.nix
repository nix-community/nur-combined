{
  lib,
  fetchFromGitea,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "iocaine";
  version = "1.1.0";

  src = fetchFromGitea {
    domain = "git.madhouse-project.org";
    owner = "iocaine";
    repo = "iocaine";
    tag = "iocaine-${version}";
    hash = "sha256-1gFFUpm7yrPNd7V4BFMud4Su0RKTV6v/J71qWtdoNuI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-aaKy3RlNTdg3TW1CuT+BYS2eMDzptvcwieTASgOsNv8=";

  meta = with lib; {
    description = "The deadliest poison known to AI";
    license = licenses.mit;
    platforms = platforms.linux;
    homepage = "https://iocaine.madhouse-project.org/";
    mainProgram = "iocaine";
  };
}
