{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule (finalAttrs: {
  pname = "hugomods-code-block-panel";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "hugomods";
    repo = "code-block-panel";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7JQ4DbV3dbZX9g5cTXfz3W1YGe+4Q1jWhD2yJ85FWeA=";
  };

  vendorHash = "sha256-a8U3MDiVki5lEe2lA56qjN3oX7Oh5YS1cJluXI/iLfE=";

  ldflags = [ "-s" "-w" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hugomods/code-block-panel
    cp -r . $out/share/hugomods/code-block-panel

    runHook postInstall
  '';

  meta = {
    description = "Computer: Hugo Code Block Panel Module";
    homepage = "https://github.com/hugomods/code-block-panel.git";
    changelog = "https://github.com/hugomods/code-block-panel/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    #mainProgram = "code-block-panel";
  };
})
