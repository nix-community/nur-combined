{
  lib,
  fetchFromGitHub,
  rustPlatform,
  tzdata,
  ...
}: let
  pname = "tackler";
  owner = "tackler-ng";
  version = "v25.05.1";
  src = fetchFromGitHub {
    owner = owner;
    repo = pname;
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-Z/gSLEZp4ZWiz3PzLhZdRSmuW7/hbccAG8EpiyQry2c=";
  };
in
  rustPlatform.buildRustPackage {
    pname = pname;
    version = version;
    src = src;

    cargoHash = "sha256-CfBpR1lX4K6d8105hRquPFexp6Fj7+zmKwsm/8ia2KI=";

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
