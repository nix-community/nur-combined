{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-03-06";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "3170e83b03eefc15e5a3707e5c52dc726ffcd60a";
      sha256 = "1k6419x4jvkb6w8xczvqfmkndnlqllilsk31w7cv8z164dpl55y3";
    };
  };

in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {

  # This is needed to ensure install targets are created
  postPatch = ''
    sed -i 's/add_executable/add_llvm_tool/' tools/*/CMakeLists.txt
  '';
}
