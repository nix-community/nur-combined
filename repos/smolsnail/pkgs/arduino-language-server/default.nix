{ lib, buildGoModule, fetchFromGitHub, arduino-cli, clang-tools }:

let
  base-name = "arduino-language-server";
in buildGoModule {
  pname = "${base-name}-unstable";
  version = "2021-10-19";

  src = fetchFromGitHub {
    owner = "arduino";
    repo = base-name;
    rev = "68ebb5d40f5130496cb1ab39108ac594008f2163";
    sha256 = "0zajg1y7a8cd2222z6gyl9k6kvj5jpmbjbhjnzc7jwhxh0s9kf13";
  };

  vendorSha256 = "038d2v9xx1d47zad5kcm2f7hkj6iq3j9l0jfdi1ygprrdcqkmwgh";

  meta = with lib; {
    description = "An Arduino Language Server based on Clangd to Arduino code autocompletion";
    longDescription = ''
      The Arduino Language Server is the tool that powers the autocompletion of the new Arduino IDE 2.
      It implements the standard Language Server Protocol so it can be used with other IDEs as well.
    '';
    homepage = "https://github.com/arduino/arduino-language-server";
    license = licenses.asl20;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
