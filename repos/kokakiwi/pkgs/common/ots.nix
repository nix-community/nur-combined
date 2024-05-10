{ lib, fetchFromGitHub }:
rec {
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-oc90iJHRieZD7RSf1wF420957nsypPWIgM3dz/wLhIE=";
  };
}
