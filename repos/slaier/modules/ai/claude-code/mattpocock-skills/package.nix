{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mattpocock-skills";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XqF709Y9GMKINzZITlbCTyatG9AxRZh0qn2vcv1Z8yo=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/skills"

    # Install reusable workflow/engineering skills only.
    for skill in \
      skills/productivity/grilling \
      skills/engineering/tdd
    do
      cp -R "$skill" "$out/share/skills/$(basename "$skill")"
    done

    runHook postInstall
  '';

  meta = {
    description = "Selected reusable skills from mattpocock/skills";
    homepage = "https://github.com/mattpocock/skills";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
