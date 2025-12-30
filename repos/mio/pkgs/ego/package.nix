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
  version = "1.1.7-unstable-20251231";

  src = fetchFromGitHub {
    owner = "mio-19";
    repo = "ego";
    rev = "eb1ae0b52bc194d93e08d24f882f401ced414ec0"; # version;
    hash = "sha256-6KoEV53c3XV2CJ9PHK4c3bjZv3ulQhkWuwZr1vp6E3Q=";
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
