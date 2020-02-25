{ stdenv, fetchFromGitHub
, git
}:

stdenv.mkDerivation rec {
  pname = "githooks";
  version = "1912.161811-71df49";

  src = fetchFromGitHub {
    owner = "rycus86";
    repo = "githooks";
    rev = "01206b5b9aeef707dea8d6954f730a8ba8dfeed1";
    sha256 = "178nbm1ybhyjanqjpgbjxh9f61ysahlc4qlkr86l799hjaw3blzl";
  };

  configurePhase = ''
    runHook preConfigure
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    sh "$src"/install.sh --prefix "$out"

    runHook postInstall
  '';

  meta = let inherit (stdenv) lib; in {
    description = "Per-repo and global Git hooks with version control";
    homepage = https://github.com/rycus86/githooks;
    license = lib.licenses.mit;
    maintainers = let m = lib.maintainers; in [ m.bb010g ];
    platforms = lib.platforms.all;
  };
}
