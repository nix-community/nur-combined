{ patchelf, fetchFromGitHub, autoreconfHook }:

patchelf.overrideAttrs (o : rec {
  name = "patchelf-${version}";
  version = "2018-09-27";

  nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ autoreconfHook ];

  src = fetchFromGitHub {
    owner  = "dtzWill";
    repo = "patchelf";
    rev = "cc23a2777f4c25d192557df7b86e7b7882a2fa0e";
    sha256 = "1b70sbmahnr8xwk5511vzalvck2125551m0caysjhh4q9azhi2kh";
  };
})

