{ patchelf, fetchFromGitHub, autoreconfHook }:

patchelf.overrideAttrs (o : rec {
  name = "patchelf-${version}";
  version = "2019-03-28";

  nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ autoreconfHook ];

  src = fetchFromGitHub {
    owner  = "NixOS";
    repo = "patchelf";
    rev = "e1e39f3639e39360ceebb2f7ed533cede4623070";
    sha256 = "09q1b1yqfzg1ih51v7qjh55vxfdbd8x5anycl8sfz6qy107wr02k";
  };
})
