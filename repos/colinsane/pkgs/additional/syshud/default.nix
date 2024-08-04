{ lib, stdenv
, fetchFromGitHub
, gtk4-layer-shell
, gtkmm4
, pkg-config
, nix-update-script
, wireplumber
, wrapGAppsHook4
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "syshud";
  version = "0-unstable-2024-08-03";

  src = fetchFromGitHub {
    owner = "System64fumo";
    repo = "syshud";
    rev = "ea0b6a52e110d18783a418013c1be82ff32709a7";
    hash = "sha256-MLVjdPcnSHCxQ9KbmM1V/jnmh7NrzZZAg13D3a240Q0=";
  };
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'pkg-config' ''${PKG_CONFIG}
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4  #< to plumb `GDK_PIXBUF_MODULE_FILE` through, and get not-blurry icons
  ];

  buildInputs = [
    gtk4-layer-shell
    gtkmm4
    wireplumber
  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
  ];

  # populate version info used by `syshud -v`:
  configurePhase = ''
    runHook preConfigure

    echo '#define GIT_COMMIT_MESSAGE "${finalAttrs.src.rev}"' >> src/git_info.hpp
    echo '#define GIT_COMMIT_DATE "${lib.removePrefix "0-unstable-" finalAttrs.version}"' >> src/git_info.hpp

    runHook postConfigure
  '';

  # syshud manually `dlopen`'s its library component
  postInstall = ''
    wrapProgram $out/bin/syshud --prefix LD_LIBRARY_PATH : $out/lib
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version" "branch" ];
  };

  meta = {
    description = "Simple heads up display written in gtkmm 4";
    homepage = "https://github.com/System64fumo/syshud";
    mainProgram = "syshud";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
