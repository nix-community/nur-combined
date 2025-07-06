{
  lib,
  fetchFromGitea,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "iocaine";
  version = "2.4.1";

  src = fetchFromGitea {
    domain = "git.madhouse-project.org";
    owner = "iocaine";
    repo = "iocaine";
    tag = "iocaine-${version}";
    hash = "sha256-FfekrOca/LaEzso5V4fAUF5eqQqEst0Nz2yIBanyH6g=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-kyuEWIZYKnjGDHCH4j0cwAwZLqU5Fe1iH0BeMyKG4oA=";

  meta = with lib; {
    description = "The deadliest poison known to AI";
    license = licenses.mit;
    platforms = platforms.linux;
    homepage = "https://iocaine.madhouse-project.org/";
    mainProgram = "iocaine";
  };
}
