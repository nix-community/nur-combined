{ stdenvNoCC, fetchFromGitHub } :


stdenvNoCC.mkDerivation {
  pname = "fugu-tools";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "markuskowa";
    repo = "slurm-tools";
    rev = "v1.2.2";
    sha256 = "16gf2kf3pqi96q17gvbrc6vdqxy39kg3pwg5mmsjk7zrm6hymm2x";
  };

  installPhase = ''
    mkdir -p $out/bin

    cd src
    for i in *; do
      install -m 755 -t $out/bin $i
    done
  '';
}
