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
  version = "1.1.7-unstable-20251222";

  src = fetchFromGitHub {
    owner = "mio-19";
    repo = "ego";
    rev = "7ebeebfe0e8aa0f578978f08839d8afb8c2ddcd0"; # version;
    hash = "sha256-G1Le+Kd894cZ4qS64FBE4S3aa6yroS2T2JaSrEvLyqs=";
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
