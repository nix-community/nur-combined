{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2019-02-11";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "206493694931caa8ff3133191e7a4dbb7832fd89";
      sha256 = "11dgsc3rq9valawzam6g4mi0yfns49lxsjm9bsgcgrq50y4974bq";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
