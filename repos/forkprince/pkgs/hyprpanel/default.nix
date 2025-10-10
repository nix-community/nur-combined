{
  fetchFromGitHub,
  gtk4-layer-shell,
  gtk-layer-shell,
  buildGoModule,
  symlinkJoin,
  makeWrapper,
  libadwaita,
  gdk-pixbuf,
  graphene,
  pango,
  cairo,
  gtk4,
  glib,
  lib,
}:
buildGoModule (finalAttrs: rec {
  pname = "hyprpanel";
  version = "0.3.0";

  nativeBuildInputs = [makeWrapper];

  src = fetchFromGitHub {
    owner = "pdf";
    repo = "hyprpanel";
    rev = "v${version}";
    hash = "sha256-o6tlIZx2l7WF1lna8Ye2c/miB4SwoNCJzlnB1h16trs=";
  };

  subPackages = ["cmd/${pname}" "cmd/${pname}-client"];

  vendorHash = "sha256-b39DBqIzOaNUNjm3RcLsQOQZl3pAocWcG0F2jQU25bA=";

  patches = [./fix-library.patch];

  postInstall = ''
    libPath="${finalAttrs.passthru.libraryPath}/lib"

    wrapProgram $out/bin/${pname} \
      --set PUREGOTK_LIB_FOLDER $libPath \
      --set LD_LIBRARY_PATH "$libPath"

    wrapProgram $out/bin/${pname}-client \
      --set PUREGOTK_LIB_FOLDER $libPath \
      --set LD_LIBRARY_PATH "$libPath"
  '';

  passthru.libraryPath = symlinkJoin {
    name = "${pname}-libraries";
    paths = [
      gtk4-layer-shell.dev
      gtk-layer-shell.dev
      gtk4-layer-shell
      gtk-layer-shell
      gdk-pixbuf.out
      libadwaita.out
      graphene.out
      pango.out
      glib.out
      gtk4.out
      cairo
    ];
  };

  meta = {
    description = "An opinionated panel/shell for the Hyprland compositor.";
    homepage = "https://github.com/pdf/hyprpanel";
    license = lib.licenses.mit;
    maintainers = ["Prinky"];
    platforms = ["x86_64-linux"];
    mainProgram = "hyprpanel";
    sourceProvenance = with lib.sourceTypes; [fromSource];
  };
})
