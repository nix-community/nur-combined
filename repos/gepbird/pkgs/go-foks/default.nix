pkgs:
with pkgs;

buildGoModule (finalAttrs: {
  pname = "go-foks";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "foks-proj";
    repo = "go-foks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BeDhq+963G7OA164HcBJ8njfwPhRbMxPuckk7V538WI=";
  };

  vendorHash = "sha256-8/SVOWMoCfeiuH2As2cC/HLRs1WQIQ4/Ko1olXDq6bo=";

  nativeBuildInputs = [
    pkg-config
    pcsclite
    pcsclite.lib
  ];

  buildInputs = [
    pcsclite
    pcsclite.lib
  ];

  doCheck = false;
})
