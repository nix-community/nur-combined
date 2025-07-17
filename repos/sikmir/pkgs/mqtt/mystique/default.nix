{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "mystique";
  version = "0-unstable-2022-11-25";

  src = fetchFromGitHub {
    owner = "TheThingsIndustries";
    repo = "mystique";
    rev = "80ab21781b6d29cee3f05905cb2842e4bef3834e";
    hash = "sha256-8qcjXvCBHlv0lM5tNjbMv/HLAHyF0gFBFrNo5g6p7h8=";
  };

  vendorHash = "sha256-Pf/FwpDMmeAKnNybj/tHlbbfhNKT2UPTVTodhoulNY8=";

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "MQTT Server";
    homepage = "https://github.com/TheThingsIndustries/mystique";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
