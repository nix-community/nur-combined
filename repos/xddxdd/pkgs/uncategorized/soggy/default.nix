{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  cmake,
  protobuf3_21,
  protobufc,
  lua5_3_compat,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "soggy";
  version = "0-unstable-2022-12-14";
  src = fetchFromGitHub {
    owner = "LDAsuku";
    repo = "soggy";
    rev = "2736cb094a51d186dabf2204a7599e9b8118f8dd";
    hash = "sha256-pv/5CxmojkfOwE/r1T2Ow96XkFw/FQvLcY49bWWiEwo=";
  };
  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    protobuf3_21
    protobufc
    lua5_3_compat
  ];

  patches = [ ./fix-cstdint-include.patch ];

  installPhase = ''
    runHook preInstall

    install -Dm755 soggy $out/bin/soggy
    install -Dm644 $src/soggy.cfg $out/opt/soggy.cfg
    cp -r $src/static $out/opt/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Experimental server emulator for a game I forgot its name";
    homepage = "https://github.com/LDAsuku/soggy";
    license = lib.licenses.agpl3Only;
    mainProgram = "soggy";
    broken = true;
  };
})
