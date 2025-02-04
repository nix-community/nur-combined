{
  lib,
  fetchFromGitHub,
  rustPlatform,
  tzdata,
  ...
}: let
  pname = "tackler-ng";
  owner = "e257-fi";
  version = "v25.01.1";
  src = fetchFromGitHub {
    owner = owner;
    repo = pname;
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-b3gG96rxdZP+2ny8eKGzTIB/FjQHYzx02RXXcKIKHw4=";
  };
in
  rustPlatform.buildRustPackage {
    pname = pname;
    version = version;
    src = src;

    cargoHash = "sha256-xxhnXI9zbWt1rWTUZbyj/4AXEQGSB2VStuGdwWw+eaU=";

    nativeBuildInputs = [tzdata];
    env = {
      TZDIR = "${tzdata}/share/zoneinfo";
    };

    meta = {
      description = "Fast, reliable bookkeeping engine with native GIT SCM support for plain text accounting";
      homepage = "https://github.com/${owner}/${pname}";
      license = lib.licenses.asl20;
      maintainers = ["github.com/ossareh"];
    };
  }
