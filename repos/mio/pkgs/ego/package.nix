{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeBinaryWrapper,
  acl,
  libxcb-util,
  xorg,
}:

rustPlatform.buildRustPackage rec {
  pname = "ego";
  version = "1.1.7-unstable-20260107";

  src = fetchFromGitHub {
    owner = "intgr";
    repo = "ego";
    rev = "33798378f719c376ed215c6725223c44d3c9dce9"; # version;
    hash = "sha256-GJSCNQ+KxQEdkbfkKD/fniB/Ta2d6zqvU56oe7DK4j8=";
  };

  buildInputs = [
    acl
    libxcb-util
  ];

  nativeBuildInputs = [ makeBinaryWrapper ];

  cargoHash = "sha256-8CQUyUEh5yzuECol+EqO+I+HNJ28fmeIf2AsnTakEfg=";

  # requires access to /root
  checkFlags = [
    "--skip tests::test_check_user_homedir"
  ];

  postInstall = ''
    wrapProgram $out/bin/ego --prefix PATH : ${lib.makeBinPath [ xorg.xhost ]}
  '';

  meta = {
    description = "Run Linux desktop applications under a different local user";
    homepage = "https://github.com/intgr/ego";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dit7ya ];
    mainProgram = "ego";
  };
}
