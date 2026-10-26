{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "helix-fcitx-focus";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "mtul0729";
    repo = "helix-fcitx-focus";
    rev = "d2572a926b9c71ee1f61666cff27a76096d1b323";
    hash = "sha256-Uo24YqtguCZD1nJL16+cI3GNJQfssFP2rRgUBSBNUxM=";
  };

  cargoHash = "sha256-LVNwdhn2h50un3r391JwPJiPhlTmRPl863rqB595RKo=";

  installPhase = ''
    runHook preInstall

    install -Dm755 "$(find target -name libhelix_fcitx_focus.so -type f -print -quit)" \
      $out/lib/libhelix_fcitx_focus.so
    install -Dm644 cog.scm $out/share/steel/cogs/helix-fcitx-focus/cog.scm
    cp -r cogs $out/share/steel/cogs/helix-fcitx-focus/cogs

    runHook postInstall
  '';

  meta = {
    description = "Fcitx5 input method switching for Helix Steel";
    homepage = "https://github.com/mtul0729/helix-fcitx-focus";
    license = with lib.licenses; [
      mit
      asl20
    ];
    platforms = lib.platforms.linux;
  };
}
