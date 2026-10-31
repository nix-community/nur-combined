{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "i-have-adhd";
  version = "0.4.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "ayghri";
    repo = "i-have-adhd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GTqrnZxQvzo/ogAuUrffkOaMK1BYm/4rAZsnfmDt7DU=";
  };

  installPhase = ''
    runHook preInstall

    cp -r . $out
    rm -rf $out/.github $out/tests $out/scripts $out/evals \
      $out/README.md $out/INSTALL.md $out/AGENTS.md $out/CONTRIBUTING.md \
      $out/.gitignore

    runHook postInstall
  '';

  meta = {
    description = "ADHD-friendly output shaping for coding agents";
    homepage = "https://github.com/ayghri/i-have-adhd";
    downloadPage = "https://github.com/ayghri/i-have-adhd/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
