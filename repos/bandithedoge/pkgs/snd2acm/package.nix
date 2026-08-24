{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  libvorbis,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "snd2acm";
  version = "7.7j+0.0.1fix";
  src = fetchFromGitHub {
    owner = "dtiefling";
    repo = "snd2acm-portable";
    rev = "v${finalAttrs.version}";
    hash = "sha256-co7b0T/ZDyj7rcA2OJbYItl+ueQYuJ2QhinUGyBavHg=";
  };

  buildInputs = [
    libvorbis
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r bin $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sound to ACM converter based on The DragonLance Total Conversion Editor Pro (DLTCEP) code";
    homepage = "https://github.com/dtiefling/snd2acm-portable";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "snd2acm";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
