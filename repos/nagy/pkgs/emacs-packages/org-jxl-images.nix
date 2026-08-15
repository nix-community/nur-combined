{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "org-jxl-images";
  version = "0-unstable-2026-08-02";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "org-jxl-images.el";
    rev = "8c72ff9f7e8726ea6a149e8d343c6c381d6971d5";
    hash = "sha256-2D9dlJal0NZ25h6BUZI2+jAkeZHjnh2HZmMZqkmUui8=";
  };

  meta = {
    homepage = "https://github.com/nagy/org-jxl-images.el";
    description = "Inline JPEG XL images in Org mode";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
