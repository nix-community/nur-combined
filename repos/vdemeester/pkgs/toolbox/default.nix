{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "toolbox";
  version = "0.0.92";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "toolbox";
    rev = "${version}";
    sha256 = "0lqrhqpi012m9qadh9lgqmqshfwfkmfd0h5nfg7692rza0gkiy85";
  };

  phases = "unpackPhase installPhase";

  installPhase = ''
    mkdir $out
    install -D toolbox $out/bin/toolbox
    install -D profile.d/toolbox.sh $out/share/toolbox/profile.d/toolbox.sh
    sed -i 's%/etc/profile.d/%$out/share/toolbox/profile.d/%g' toolbox
    mkdir -p $out/share/bash-completion/completions/
    cp completion/bash/toolbox $out/share/bash-completion/completions/toolbox
  '';
}
