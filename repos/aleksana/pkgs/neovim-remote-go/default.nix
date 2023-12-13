{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "neovim-remote-go";
  version = "unstable-2022-01-09";

  src = fetchFromGitHub {
    owner = "Aleksanaa";
    repo = "neovim-remote-go";
    rev = "e21faff711124835fa826a8b25a3ab80d3fbee45";
    hash = "sha256-x9fMEoCMdI4CmyQF969voggKJ3D+uE8MRMw2AfXBkOM=";
  };

  vendorHash = "sha256-osduDunniiEH4O5sNSUocmS+A9TjAOv7K7x/JQ4y1GE=";

  doCheck = false;

  meta = with lib; {
    description = "alternative to neovim-remote";
    license = licenses.mit;
  };
}
