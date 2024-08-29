# This file has been generated by node2nix 1.11.1. Do not edit!

{nodeEnv, fetchurl, fetchgit, nix-gitignore, stdenv, lib, globalBuildInputs ? []}:

let
  sources = {
    "node-addon-api-4.3.0" = {
      name = "node-addon-api";
      packageName = "node-addon-api";
      version = "4.3.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/node-addon-api/-/node-addon-api-4.3.0.tgz";
        sha512 = "73sE9+3UaLYYFmDsFZnqCInzPyh3MqIwZO9cw58yIqAZhONrrabrYyYe3TuIqtIiOuTXVhsGau8hcrhhwSsDIQ==";
      };
    };
    "node-gyp-build-4.8.2" = {
      name = "node-gyp-build";
      packageName = "node-gyp-build";
      version = "4.8.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/node-gyp-build/-/node-gyp-build-4.8.2.tgz";
        sha512 = "IRUxE4BVsHWXkV/SFOut4qTlagw2aM8T5/vnTsmrHJvVoKueJHRc/JaFND7QDDc61kLYUJ6qlZM3sqTSyx2dTw==";
      };
    };
    "q-1.5.1" = {
      name = "q";
      packageName = "q";
      version = "1.5.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/q/-/q-1.5.1.tgz";
        sha512 = "kV/CThkXo6xyFEZUugw/+pIOywXcDbFYgSct5cT3gqlbkBE1SJdwy6UQoZvodiWF/ckQLZyDE/Bu1M6gVu5lVw==";
      };
    };
    "usb-1.9.2" = {
      name = "usb";
      packageName = "usb";
      version = "1.9.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/usb/-/usb-1.9.2.tgz";
        sha512 = "dryNz030LWBPAf6gj8vyq0Iev3vPbCLHCT8dBw3gQRXRzVNsIdeuU+VjPp3ksmSPkeMAl1k+kQ14Ij0QHyeiAg==";
      };
    };
  };
in
{
  teck-programmer = nodeEnv.buildNodePackage {
    name = "teck-programmer";
    packageName = "teck-programmer";
    version = "1.1.1";
    src = fetchurl {
      url = "https://registry.npmjs.org/teck-programmer/-/teck-programmer-1.1.1.tgz";
      sha512 = "bfg3TwaPBG/R2FGPyUQD/MDhWcdqvuflBzI5VsQPJD/EuPnCE/rUPKXaLvhDaz2szzz8xYcv+t10yhKuX5PYWA==";
    };
    dependencies = [
      sources."node-addon-api-4.3.0"
      sources."node-gyp-build-4.8.2"
      sources."q-1.5.1"
      sources."usb-1.9.2"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "Programmer for TECK keyboards.";
      homepage = "https://github.com/m-ou-se/teck-programmer";
      license = "GPL-3.0+";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
  node-gyp-build = nodeEnv.buildNodePackage {
    name = "node-gyp-build";
    packageName = "node-gyp-build";
    version = "4.8.2";
    src = fetchurl {
      url = "https://registry.npmjs.org/node-gyp-build/-/node-gyp-build-4.8.2.tgz";
      sha512 = "IRUxE4BVsHWXkV/SFOut4qTlagw2aM8T5/vnTsmrHJvVoKueJHRc/JaFND7QDDc61kLYUJ6qlZM3sqTSyx2dTw==";
    };
    buildInputs = globalBuildInputs;
    meta = {
      description = "Build tool and bindings loader for node-gyp that supports prebuilds";
      homepage = "https://github.com/prebuild/node-gyp-build";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}