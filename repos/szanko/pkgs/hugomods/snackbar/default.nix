{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule (finalAttrs: {
  pname = "hugomods-snackbar";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "hugomods";
    repo = "snackbar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Gh95fyXIQfR0MPXfX95wUDPVuGyz4hl2/jpGJ9qcm+Q=";
  };

  vendorHash = null;

  ldflags = [ "-s" "-w" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hugomods/snackbar
    cp -r . $out/share/hugomods/snackbar

    runHook postInstall
  '';

  meta = {
    description = "Right_anger_bubble: Hugo Snackbar Module";
    homepage = "https://hugomods.com/docs/snackbar/";
    changelog = "https://github.com/hugomods/snackbar/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    #mainProgram = "hugomods-snackbar";
  };
})
