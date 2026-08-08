{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "scroll-page-without-moving-point";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "tanrax";
    repo = "scroll-page-without-moving-point.el";
    rev = "a7344713c61d32339162df50ed7d77d11d5b3505";
    hash = "sha256-JhaoGq8NSMQzpSm7PIEIO5nC+ngJOXvBviuaCKba9xQ=";
  };

  meta = {
    homepage = "https://github.com/tanrax/scroll-page-without-moving-point.el";
    description = "Scroll the page without moving the cursor position";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
