{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mmm";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-XYNOyMdlZTt2qeQfAwGdWtvauzvQ8nAHGHRsoYX8jeQ=";
  };

  vendorHash = "sha256-q5sDsRmfWbIeLp9aFVTCtxJfAvSspuCxVgUYqxTTwiU=";
  proxyVendor = true;

  meta = with lib; {
    description = "Matrix media manager";
    license = lib.licenses.asl20;
    homepage = "https://github.com/meain/${pname}";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
