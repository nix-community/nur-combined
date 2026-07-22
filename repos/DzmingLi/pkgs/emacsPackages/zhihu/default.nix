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
    rev = "a032419e159054abe20ef157c388dd4d9a0ae677";
    hash = "sha256-cuENcA7juNgHE1HnrqnZptFprUejK8xLZeeB3ll5gZ8=";
  };

  packageRequires = with emacsPackages; [ yaml ];

  meta = with lib; {
    description = "Write and publish Zhihu answers and articles from Emacs";
    homepage = "https://github.com/DzmingLi/zhihu.el";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
