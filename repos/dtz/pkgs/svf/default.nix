{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-18";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "4be49ef34cb7b6f884b4384ede6c4ef26c06b7a6";
      sha256 = "1rghfx5j53m5b1xn3y64zng8larm9m4hshy2k8xziadb4x890527";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
