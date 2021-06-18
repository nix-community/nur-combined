{ pkgs, fetchFromGitLab, ... }@inputs:

pkgs.st.overrideAttrs (oldAttrs: rec {
  __contentAddressed = true;
  # src = inputs.st;
  src = fetchFromGitLab {
    owner = "ethancedwards";
    repo = "st-config";
    rev = "8dfefc7d84c4aa1785cd583fd027b90fd9df9771";
    sha256 = "aAkLLrZkwKsQWRTxJRbjrdLbeq01eMrvQhldF5kQBTk=";
  };
})
