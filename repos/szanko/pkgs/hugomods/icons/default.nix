{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule (finalAttrs: {
  pname = "hugomods-icons";
  version = "0-unstable-2026-01-02";

  src = fetchFromGitHub {
    owner = "hugomods";
    repo = "icons";
    rev = "87b327f3d499daad97f838faa6ce75da4415ade7";
    hash = "sha256-5RB17DkS/hhfYC8E/hykbl2JJflbHju1qY+A0zkEmn4=";
  };

  vendorHash = null;


  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hugomods/icons
    cp -r . $out/share/hugomods/icons

    runHook postInstall
  '';

  ldflags = [ "-s" ];

  meta = {
    description = "Art: Hugo SVG Icons Module that compatible any SVG image vendors, i.e. Bootstrap, Font Awesome, Simple Icons";
    homepage = "https://github.com/hugomods/icons";
    changelog = "https://github.com/hugomods/icons/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "hugomods-icons";
  };
})
