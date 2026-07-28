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
    rev = "cea464447dce72e183d65568a96842dc2ac7baf8";
    hash = "sha256-mMI8EE8ae8RvBqBFAv2MpzATciC1GIkoFtBV/PeywCE=";
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
