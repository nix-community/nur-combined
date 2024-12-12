{ fetchFromGitHub, nng }:

nng.overrideAttrs (super: rec {
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "emqx";
    repo = "NanoSDK";
    tag = version;
    hash = "sha256-wg9LgHMu5iywesFoQwqU5xp0cxFgtnZNhfCc4J7uMMI=";
    fetchSubmodules = true;
  };
})
