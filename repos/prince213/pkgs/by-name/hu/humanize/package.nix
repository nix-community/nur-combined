{
  lib,
  fetchFromGitHub,
  stdenvNoCC,

  # nativeBuildInputs
  installAgentSkills,
}:

stdenvNoCC.mkDerivation {
  pname = "humanize";
  version = "0-unstable-2026-09-22";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "harshaneel";
    repo = "humanize";
    rev = "9c3dec34dc8e0ed9d26de14a869900a714da8f9e";
    hash = "sha256-YaEnNER6lrj/yl1kdb19Uf17S623mDpbCMmP2Q5DM8Q=";
  };

  nativeBuildInputs = [ installAgentSkills ];

  meta = {
    description = "Skills that strip AI tells from text and score text for remaining ones";
    homepage = "https://github.com/harshaneel/humanize";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
}
