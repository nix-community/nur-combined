{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## DzmingLi/zhihu.el: write and publish Zhihu answers and articles from Emacs.
##
## Consumer (with this repository's overlay enabled):
##   emacsWithPackages (epkgs: [ ... epkgs.zhihu ... ])
emacsPackages.trivialBuild {
  pname = "zhihu";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "zhihu.el";
    rev = "67e489171397c0cf3aae784254f120bf7b6ddeba";
    hash = "sha256-bn9+/rs8/maph7hOtyHsmY4fZWCiwDm+rHqTG5GcQew=";
  };

  packageRequires = with emacsPackages; [ yaml ];

  meta = with lib; {
    description = "Write and publish Zhihu answers and articles from Emacs";
    homepage = "https://github.com/DzmingLi/zhihu.el";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
