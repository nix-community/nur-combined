{ stdenvNoCC, fetchFromGitHub } :

let
  src = fetchFromGitHub {
    owner = "markuskowa";
    repo = "slurm-tools";
    rev = "v1.2.2";
    sha256 = "16gf2kf3pqi96q17gvbrc6vdqxy39kg3pwg5mmsjk7zrm6hymm2x";
  };
in
  (import src) { inherit stdenvNoCC; }
