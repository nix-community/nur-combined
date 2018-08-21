{ patchelf, fetchFromGitHub, autoreconfHook }:

patchelf.overrideAttrs (o : rec {
  name = "patchelf-${version}";
  version = "2018-05-09";

  nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ autoreconfHook ];

  src = fetchFromGitHub {
    owner  = "NixOS";
    repo = "patchelf";
    rev = "27ffe8ae871e7a186018d66020ef3f6162c12c69";
    sha256 = "1sfkqsvwqqm2kdgkiddrxni86ilbrdw5my29szz81nj1m2j16asr";
  };
})
