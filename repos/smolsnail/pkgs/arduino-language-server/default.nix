{ lib, buildGoModule, fetchFromGitHub, arduino-cli, clang-tools }:

buildGoModule rec {
  pname = "arduino-language-server";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "arduino";
    repo = pname;
    rev = version;
    sha256 = "1nrqasn8c2wzvb6bvv2izb05sqgv8frri1zfn4pivf9ywnlqwzad";
  };

  vendorSha256 = "0kfn9jy59whw41vn07r536qjzl7vpgm51dp3qnh25b174lg0j7x7";

  meta = with lib; {
    description =
      "An Arduino Language Server based on Clangd to Arduino code autocompletion";
    longDescription = ''
      The Arduino Language Server is the tool that powers the autocompletion of the new Arduino IDE 2.
      It implements the standard Language Server Protocol so it can be used with other IDEs as well.
    '';
    homepage = "https://github.com/arduino/arduino-language-server";
    license = licenses.asl20;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
