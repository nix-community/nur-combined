{
  lib,
  fetchFromGitHub,
  stdenvNoCC,

  # nativeBuildInputs
  installAgentSkills,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "humanizer";
  version = "3.1.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "blader";
    repo = "humanizer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n8cbTzhlGf8VnWpPukq7XD2mucIrqyE1XMpAAc5oA8A=";
  };

  nativeBuildInputs = [ installAgentSkills ];

  preInstall = ''
    rm -rf .github scripts AGENTS.md CHANGELOG.md LICENSE README.md
  '';

  meta = {
    description = "Agent skill that removes signs of AI-generated writing from text";
    homepage = "https://github.com/blader/humanizer";
    changelog = "https://github.com/blader/humanizer/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
