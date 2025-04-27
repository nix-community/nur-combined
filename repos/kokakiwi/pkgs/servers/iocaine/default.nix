{
  lib,
  fetchFromGitea,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "iocaine";
  version = "2.1.0";

  src = fetchFromGitea {
    domain = "git.madhouse-project.org";
    owner = "iocaine";
    repo = "iocaine";
    tag = "iocaine-${version}";
    hash = "sha256-7avS203Le/m3/H685ysfRjg0eA7aJxncg398Ln4RXDE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-zw9LvY5w28ttHTowyV47S/nMj8J+hRFG4yJSe5+oD8k=";

  meta = with lib; {
    description = "The deadliest poison known to AI";
    license = licenses.mit;
    platforms = platforms.linux;
    homepage = "https://iocaine.madhouse-project.org/";
    mainProgram = "iocaine";
  };
}
