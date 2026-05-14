{ lib
, fetchFromGitHub
, fetchNpmDeps
, llama-cpp-vulkan
, installShellFiles
, nodejs
, npmHooks
, openssl
, spirv-headers
}:

llama-cpp-vulkan.overrideAttrs (prev: rec {
  version = "9150";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    tag = "b${version}";
    hash = "sha256-eWWUmzuUggU0VM3ITSge4rDKJ9ntAwP6wCcBb1W9yZk=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  nativeBuildInputs = prev.nativeBuildInputs ++ [
    installShellFiles
    nodejs
    npmHooks.npmConfigHook
  ];

  buildInputs = prev.buildInputs ++ [ openssl spirv-headers ];

  npmRoot = "tools/server/webui";
  npmDepsHash = "sha256-cV3noOyKmst9vfxyvkCNhihPgwfVGhmPPT4UMloeWZM=";
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

  cmakeFlags = prev.cmakeFlags ++ [
    (lib.cmakeBool "LLAMA_OPENSSL" true)
  ];
})
