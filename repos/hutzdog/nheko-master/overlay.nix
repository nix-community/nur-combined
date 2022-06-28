final: prev: {
  mtxclient-master = let
    rev = "e93779692fcc00de136234dd48d0af354717b0a1";
  in prev.mtxclient.overrideAttrs (old: {
    version = "master-${rev}";
    src = prev.fetchFromGitHub {
      owner = "Nheko-Reborn";
      repo = "mtxclient";
      inherit rev;
      sha256 = "UhatxC/Fc9KyKVjJw/pTO3GeIEs1Fwdq1bWl39Dk3I0=";
    };
  });

  nheko-master = let
    rev = "7a295317397d5e49b66c39605c6529d99660691c";
  in (prev.nheko.overrideAttrs (old: {
    version = "master-${rev}";
    src = prev.fetchFromGitHub {
      owner = "Nheko-Reborn";
      repo = "nheko";
      inherit rev;
      sha256 = "n4Oca0Xw5WtY0PzRxhF68z0xcve/c6+UHOAw03YI4RY=";
    };
  })).override {
    mtxclient = final.mtxclient-master;
  };
}
