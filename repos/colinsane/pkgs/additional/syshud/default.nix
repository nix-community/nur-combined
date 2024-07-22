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
  version = "0-unstable-2024-07-21";

  src = fetchFromGitHub {
    owner = "System64fumo";
    repo = "syshud";
    rev = "4af754de4e0b43b44c803d392e0425c00ee33982";
    hash = "sha256-kiHCDISFtxR4zosBJxNFfbDHpeQT9R4cKRqZxk3ZZSY=";
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
