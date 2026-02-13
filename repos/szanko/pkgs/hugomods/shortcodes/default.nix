{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule (finalAttrs:  {
  pname = "hugomods-shortcodes";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "hugomods";
    repo = "shortcodes";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jwhniz9Weu63YkcV1WOPqjouG1l5xSG1t/Ue+gEuM/A=";
  };

  vendorHash = null;

  ldflags = [ "-s" "-w" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hugomods/shortcodes
    cp -r . $out/share/hugomods/shortcodes

    runHook postInstall
  '';

  meta = {
    description = "Computer: Extended shortcodes for Hugo, such as HTML, helpers, codes and media players";
    homepage = "https://hugomods.com/docs/shortcodes/";
    changelog = "https://github.com/hugomods/shortcodes/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    #mainProgram = "hugomods-shortcodes";
  };
})
