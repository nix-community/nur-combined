{ lib
, fetchFromGitHub
, fetchNpmDeps
, llama-cpp
, ccache
, clangStdenv
}:

(llama-cpp.override {
  vulkanSupport = true;
  stdenv = clangStdenv;
}).overrideAttrs (prev: rec {
  version = "9190";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    tag = "b${version}";
    hash = "sha256-zajArFzrLUUVsfG1xBttwzwaT9QNlKzDbvSxvof+FMQ=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  npmRoot = "tools/ui";
  npmDepsHash = "sha256-WaEePrEZ7O/7deP2KJhe0AwiSKYA8HOqETmMHUkmBe0=";
  npmDeps = fetchNpmDeps {
    name = "${prev.pname}-${version}-npm-deps";
    inherit src;
    preBuild = ''
      pushd ${npmRoot}
    '';
    hash = npmDepsHash;
  };

  preConfigure = ''
    prependToVar cmakeFlags "-DLLAMA_BUILD_COMMIT:STRING=$(cat COMMIT)"
    pushd ${npmRoot}
    npm run build
    popd
  '';

  nativeBuildInputs = prev.nativeBuildInputs ++ [
    ccache
  ];

  cmakeFlags = prev.cmakeFlags ++ [
    (lib.cmakeFeature "CMAKE_C_COMPILER_LAUNCHER" "ccache")
    (lib.cmakeFeature "CMAKE_CXX_COMPILER_LAUNCHER" "ccache")
  ];
})
