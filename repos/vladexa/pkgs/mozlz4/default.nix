{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "mozlz4";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "jusw85";
    repo = "mozlz4";
    rev = "d003163712347b2aa5e88396281ee0cb511d4638";
    hash = "sha256-csLtrErA0miCPMJMOXrDGH9RlszpZPyPSaA+zToaEzQ=";
  };

  cargoHash = "sha256-9mCMRvuWHkVBWX9BftGYtjhvePEjWptHqnXfW+vlUNs=";

  meta = with lib; {
    description = "Decompress / compress mozlz4 files";
    homepage = "https://github.com/jusw85/mozlz4";
    license = licenses.mit;
    maintainers = [
      {
        email = "vgrechannik@gmail.com";
        name = "Vladislav Grechannik";
        github = "VlaDexa";
        githubId = 52157081;
      }
    ];
    mainProgram = "mozlz4";
  };
}
