{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "rclone_zus";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "0chain";
    repo = "rclone_zus";
    tag = "v${version}";
    hash = "sha256-ovMfqz8JoyO5GT2dHUDaed0sqjzalbjEUJXCqbzIoNE=";
  };

  vendorHash = "sha256-53pJC0HD3AxjraASSFsEZawIyjBmB0hc7HKE69hN3w4=";
  proxyVendor = true;

  subPackages = ["."];

  tags = [
    "bn256"
  ];

  postInstall = ''
    mv $out/bin/rclone_zus $out/bin/rclone
  '';

  meta = {
    description = "Command line program to sync files and directories to and from Züs storage";
    homepage = "https://github.com/0chain/rclone_zus";
    mainProgram = "rclone";
  };
}
