{ fetchFromGitHub, level-zero }:
level-zero.overrideDerivation (oldAttrs: rec {
  version = "1.19.2";
  name = "${oldAttrs.pname}-${version}";
  src = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "level-zero";
    # as seen in https://github.com/intel/llvm/blob/6a4665ef4c4b429076c589b923da9b9d5f728739/unified-runtime/cmake/FetchLevelZero.cmake#L50C38-L50C78
    tag = "v${version}";
    hash = "sha256-MnTPu7jsjHR+PDHzj/zJiBKi9Ou/cjJvrf87yMdSnz0=";
  };
})
