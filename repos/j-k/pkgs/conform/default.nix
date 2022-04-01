{ lib, buildGoModule, fetchFromGitHub, git }:

buildGoModule rec {
  pname = "conform";
  version = "0.1.0-alpha.25";

  src = fetchFromGitHub {
    owner = "talos-systems";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-WgWgigpqPoEBY4tLjbzK02WFwrCWPGQWJ5eakLv5IWw=";
  };
  vendorSha256 = "sha256-Oigt7tAK4jhBQtfG1wdLHqi11NWu6uJn5fmuqTmR76E=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/talos-systems/conform/cmd.Tag=v${version}"
  ];

  checkInputs = [ git ];

  meta = with lib; {
    homepage = "https://github.com/talos-systems/conform";
    changelog = "https://github.com/talos-systems/conform/blob/v${version}/CHANGELOG.md";
    description = "Policy enforcement for your pipelines";
    longDescription = ''
      Conform is a tool for enforcing policies on your build pipelines
    '';
    license = licenses.mpl20;
    maintainers = with maintainers; [ jk ];
  };
}
