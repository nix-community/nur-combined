{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

emacsPackages.trivialBuild {
  pname = "org-flyimage";
  version = "0-unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "misohena";
    repo = "org-inline-image-fix";
    rev = "760a8a8cc4b0c4c1d3279df852dbe7a87ed197de";
    hash = "sha256-Ddusj3DTQ22f2JDdHPkt3uaveNGSxTJuaf/uqHrZIhA=";
  };

  packageRequires = [ emacsPackages.org ];
  # The upstream repository contains several independent Org extensions.
  postPatch = ''
    find . -maxdepth 1 -name '*.el' ! -name 'org-flyimage.el' -delete
  '';

  meta = with lib; {
    description = "Automatically update inline images in Org mode";
    homepage = "https://github.com/misohena/org-inline-image-fix";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
