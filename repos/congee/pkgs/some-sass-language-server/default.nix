{
  lib,
  stdenvNoCC,
  fetchurl,
  versionCheckHook,
  nodejs,
}:

stdenvNoCC.mkDerivation rec {
  pname = "some-sass-language-server";
  version = "2.3.8";

  src = fetchurl {
    url = "https://registry.npmjs.org/some-sass-language-server/-/some-sass-language-server-${version}.tgz";
    hash = "sha256-dTNM1MBb5RLwySTMZZWvHtwlpoSdlRQnG6hzaYpVXaw=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    mv bin dist package.json $out/

    runHook postInstall
  '';

  buildInputs = [ nodejs ];

  doInstallCheck = true;
  versionCheckProgramArg = "--version";
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Language server with improved support for SCSS, Sass indented and SassDoc";
    homepage = "https://github.com/wkillerud/some-sass/tree/main/packages/language-server";
    changelog = "https://github.com/wkillerud/some-sass/releases/tag/some-sass-language-server@${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "some-sass-language-server";
  };
}
