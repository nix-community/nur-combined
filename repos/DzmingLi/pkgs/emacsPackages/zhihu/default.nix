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
    rev = "929f06307118d95df245071f1f7cbd41ded624be";
    hash = "sha256-nRIlU/o8UTmVmGIL22VPUqAX4BzvNKSWWiG4XAAGPL8=";
  };

  packageRequires = [
    emacsPackages.elpaDevelPackages.plz
    emacsPackages.yaml
  ];

  meta = with lib; {
    description = "Write and publish Zhihu answers and articles from Emacs";
    homepage = "https://github.com/DzmingLi/zhihu.el";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
