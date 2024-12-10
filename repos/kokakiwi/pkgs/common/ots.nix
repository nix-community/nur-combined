{ fetchFromGitHub }:
rec {
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-V2uNhzyo0gINOZRscLI0ha/DkUk7AVw8FMkYaKSrpp0=";
  };
}
