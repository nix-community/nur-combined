{ stdenv
, lib
, fetchFromGitHub
, zlib
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "ceserver";
  version = "7.5";

  src = fetchFromGitHub {
    owner = "cheat-engine";
    repo = "cheat-engine";
    rev = version;
    hash = "sha256-EG2d4iXhBGmVougCi27O27SrC+L3P4alrgnUvBsT1Ic=";
  };

  buildPhase = ''
    runHook preBuild

    pushd "Cheat Engine/ceserver/gcc"
    make
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp "Cheat Engine/ceserver/gcc/ceserver" $out/bin

    runHook postInstall
  '';

  nativeBuildInputs = [ zlib ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Cheat Engine. A development environment focused on modding";
    homepage = "https://github.com/cheat-engine/cheat-engine";
    platforms = platforms.linux;
    license = licenses.unfree;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
