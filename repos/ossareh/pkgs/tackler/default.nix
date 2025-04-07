{
  lib,
  fetchFromGitHub,
  rustPlatform,
  tzdata,
  ...
}: let
  pname = "tackler-ng";
  owner = "e257-fi";
  version = "v25.04.1";
  src = fetchFromGitHub {
    owner = owner;
    repo = pname;
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-1VlOEezEZdTigCM8kDRGmNHIwpfzWkBHeE6rZ4NzI8I=";
  };
in
  rustPlatform.buildRustPackage {
    pname = pname;
    version = version;
    src = src;

    cargoHash = "sha256-8sojWNg365kvJVX0MjWGKYFE+LkbxyFuZdXIsALQ0Xg=";

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
