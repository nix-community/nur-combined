{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "color-picker";
  version = "0.2.0-unstable-2026-09-12";

  src = fetchFromGitHub {
    owner = "zHaOdANiuu";
    repo = "color-picker.el";
    rev = "06de06e71279ffcf46f91897f5d08722e8161826";
    hash = "sha256-9NQNWiUolmMwAlJpp22Y+GOgExx0Fjq3XheM3lEVi2o=";
  };

  meta = {
    homepage = "https://github.com/zHaOdANiuu/color-picker.el";
    description = "Full color picker widget with HSV selector, sliders and favorites";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
