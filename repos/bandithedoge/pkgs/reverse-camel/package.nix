{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "reverse-camel";
  version = "0.0.4";
  src = fetchFromGitHub {
    owner = "soerenbnoergaard";
    repo = "reverse-camel";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XALdDd+HszN0JqQEHCuHNxe0jpWXfavq7EyMINLxhuk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{lv2,vst,ladspa,dssi}
    cp -r bin/reverse-camel.lv2 $out/lib/lv2
    cp bin/reverse-camel-vst.so $out/lib/vst
    cp bin/reverse-camel-ladspa.so $out/lib/ladspa
    cp bin/reverse-camel-dssi.so $out/lib/dssi

    runHook postInstall
  '';

  enableParallelBuilding = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform Camel Crusher Clone VST plug-in based on black-box analysis";
    homepage = "https://github.com/soerenbnoergaard/reverse-camel";
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
