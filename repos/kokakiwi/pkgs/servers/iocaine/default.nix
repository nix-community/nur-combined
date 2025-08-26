{
  lib,
  fetchFromGitea,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "iocaine";
  version = "2.5.0";

  src = fetchFromGitea {
    domain = "git.madhouse-project.org";
    owner = "iocaine";
    repo = "iocaine";
    tag = "iocaine-${version}";
    hash = "sha256-nj9/npZDLAsUbsH44y7rLzWCnKwzgIT2wysnHwyN438=";
  };

  cargoHash = "sha256-EE+DbESTa+HQurj/EPBfL71BC1RAAsRs/6g9cs3GUI8=";

  meta = with lib; {
    description = "The deadliest poison known to AI";
    license = licenses.mit;
    platforms = platforms.linux;
    homepage = "https://iocaine.madhouse-project.org/";
    mainProgram = "iocaine";
  };
}
