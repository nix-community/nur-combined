{
  lib,
  fetchFromGitHub,
  rustPlatform,
  tzdata,
  ...
}: let
  pname = "tackler";
  owner = "tackler-ng";
  version = "v25.06.1";
  src = fetchFromGitHub {
    owner = owner;
    repo = pname;
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-g/nbGuRtMOzI1jmNI0SfJBoJrzwZAZTRaiweMWExxlU=";
  };
in
  rustPlatform.buildRustPackage {
    pname = pname;
    version = version;
    src = src;

    cargoHash = "sha256-TKMubyPFfwNQ38QAn3ZOWOK+QGQZ9DDuWKjhw/cggVA=";

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
