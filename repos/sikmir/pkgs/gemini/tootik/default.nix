{ lib, buildGoModule, fetchFromGitHub, openssl }:

buildGoModule rec {
  pname = "tootik";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "tootik";
    rev = version;
    hash = "sha256-3QqZXy3Mv7IR/+4DZm6+1riW2NRq3mPs1ViD+7WwjtM=";
  };

  vendorHash = "sha256-2ZJ1WRrnt4aW3SC+cGgcavQqyOdgMNOLr3/f2lPeQYg=";

  nativeBuildInputs = [ openssl ];

  preBuild = ''
    go generate ./migrations
  '';

  tags = [ "fts5" ];

  meta = with lib; {
    description = "A federated nanoblogging service with a Gemini frontend";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
