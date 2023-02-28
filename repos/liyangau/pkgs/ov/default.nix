{ buildGoModule, lib, fetchFromGitHub }:

buildGoModule rec {
  pname = "ov";
  version = "0.14.2";
  sha = "ed2f3d6";

  src = fetchFromGitHub {
    owner = "noborus";
    repo = pname ;
    rev = "v${version}";
    sha256 = "sha256-tbJ3Es6huu+0HcpoiNpYLbxsm0QCWYZk6bX2MdQxT2I=";
  };

  CGO_ENABLED = 0;

  ldflags = [
    "-X main.Version=${version}"
    "-X main.Revision=${sha}"
  ];
  vendorSha256 = "sha256-EjLslvc0cgvD7LjuDa49h/qt6K4Z9DEtQjV/LYkKwKo=";

  meta = with lib; {
    description = "Feature-rich terminal-based text viewer. It is a so-called terminal pager. ";
    homepage    = "https://github.com/noborus/ov";
    license     = licenses.mit;
  };
}
