{
  stdenvNoCC,
  makeWrapper,
  python3,
}:

{
  render_templates = stdenvNoCC.mkDerivation {
    name = "render_templates";

    src = self;

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      makeWrapper ${python3.interpreter} $out/bin/render_templates \
      --add-flags "${./scripts/render_templates.py}"

      runHook postInstall
    '';
  };
}
