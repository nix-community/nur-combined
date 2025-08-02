{
  lib,
  buildDunePackage,
  fetchFromGitHub,
  makeWrapper,
  sail,
}:
buildDunePackage rec {
  pname = "isla-sail";
  version = "esop22-unstable-2025-07-06";

  src = fetchFromGitHub {
    owner = "rems-project";
    repo = "isla";
    rev = "942d5f898ba960e0723b137836099e8302e72554";
    hash = "sha256-iwk9rYFDbhKCO8CgAGRKcR5fxQS+FCv7OOgk6gxOqQU=";
  };

  sourceRoot = "${src.name}/isla-sail";

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ sail ];

  buildPhase = ''
    runHook preBuild

    dune build --release ''${enableParallelBuilding:+-j $NIX_BUILD_CORES}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 $src/isla-sail $out/bin/isla-sail
    patchShebangs --host $out/bin/isla-sail
    wrapProgram $out/bin/isla-sail --set PATH ${sail}/bin/sail

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/rems-project/isla";
    description = "Plugin for Sail that builds instruction set
    architecture specifications into a form suitable for Isla";
    maintainers = with lib.maintainers; [ definfo ];
    license = lib.licenses.bsd2;
  };
}
