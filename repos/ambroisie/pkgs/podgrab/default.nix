{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "podgrab";
  version = "2021-03-26";

  src = fetchFromGitHub {
    owner = "akhilrex";
    repo = "podgrab";
    rev = "3179a875b8b638fb86d0e829d12a9761c1cd7f90";
    sha256 = "sha256-vhxIm20ZUi+RusrAsSY54tv/D570/oMO5qLz9dNqgqo=";
  };

  vendorSha256 = "sha256-xY9xNuJhkWPgtqA/FBVIp7GuWOv+3nrz6l3vaZVLlIE=";

  postInstall = ''
    mkdir -p $out/share/
    cp -r "$src/client" "$out/share/"
    cp -r "$src/webassets" "$out/share/"
  '';

  meta = with lib; {
    description = ''
      A self-hosted podcast manager to download episodes as soon as they become live
    '';
    homepage = "https://github.com/akhilrex/podgrab";
    license = licenses.gpl3;
  };
}
