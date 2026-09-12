{
  stdenvNoCC,
  haskellPackages,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "rime-ice-modular";
  version = "2026.06.30-01";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "rime-ice-modular";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-6a85fs0Y5O55ZO7DC0onoPS9/QKFnAUmd6KNzLOkSs0=";
  };
  env.LANG = "C.UTF-8";
  nativeBuildInputs = [
    (haskellPackages.ghcWithPackages (
      ps: with ps; [
        yaml
        shake
        raw-strings-qq
        extra
        utf8-string
        aeson-pretty
      ]
    ))
  ];
  buildPhase = ''
    shake
  '';
  installPhase = ''
    mkdir -p $out
    cp -r build/* $out/
  '';
}
