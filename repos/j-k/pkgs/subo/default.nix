{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "subo";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "suborbital";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-T/EkpuqnM7EAnolMtRZyhO7W7FfIJ7DOAmaab/JKbiA=";
  };

  vendorSha256 = null;

  buildFlagsArray = [ "-ldflags=" "-s" "-w" ];

  meta = with lib; {
    description = "The Suborbital CLI";
    longDescription = ''
      Subo is the command-line helper for working with the Suborbital Development Platform.
      Subo is used to build Wasm Runnables, generate new projects and config files, and more over time.
    '';
    homepage = "https://suborbital.dev";
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
    platforms = platforms.all;
  };
}
