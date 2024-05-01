final: prev:
(prev.librime.override {
  plugins = [
    (prev.fetchFromGitHub {
      owner = "hchunhui";
      repo = "librime-lua";
      rev = "7c1b93965962b7c480d4d7f1a947e4712a9f0c5f";
      fetchSubmodules = false;
      sha256 = "sha256-H/ufyHIfYjAjF/Dt3CilL4x9uAXGcF1BkdAgzIbSGA8=";
    })
  ];
})
.overrideAttrs (old: {
  buildInputs = (old.buildInputs or []) ++ [prev.luajit];
})
