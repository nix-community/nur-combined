{ lib, pythonPackages, hostPlatform, fetchFromGitHub, fetchpatch, platform ? null }:

with pythonPackages;

buildPythonPackage rec {
  pname = "Adafruit_DHT";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "adafruit";
    repo = "Adafruit_Python_DHT";
    rev = "8f5e2c4d6ebba8836f6d31ec9a0c171948e3237d";
    sha256 = "01ya0zxawslccvh8bp5j8biylhkrfz0pjdmgzji3bcsmr4742i9f";
  };

  patches = [
    (fetchpatch {
      name = "fix-platform-detection.patch";
      url = "https://github.com/kittywitch/Adafruit_Python_DHT/commit/71c55b3ae5f0f03b525be2cc3fb8795c376b171a.patch";
      sha256 = "1iih8q9lndxqg0i83gk1ljp9dck9y6714rmcvqlycmc25zkiw3hz";
    })
  ];

  setupPyGlobalFlags = let
    defaultPlatform = {
      "armv6l-linux" = "pi";
      # For Beaglebone Black owners, platform must be explicitly provided as "bbb".
      "armv7l-linux" = "pi2";
      "aarch64-linux" = "pi2";
    }.${hostPlatform.system};
    platformStr = if platform == null then defaultPlatform else platform;
  in lib.singleton "--force-${platformStr}";
  format = "setuptools";
  doCheck = false;

  meta = {
    broken = python.isPy2;
    platforms = [ "armv6l-linux" "armv7-linux" "aarch64-linux" ];
  };
}
