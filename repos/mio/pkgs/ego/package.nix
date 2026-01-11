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
  version = "1.2.0-unstable-20260110";

  src = fetchFromGitHub {
    owner = "intgr";
    repo = "ego";
    rev = "dd4ae1040919c551b894a76a7ec5301111ba9dc9"; # version;
    hash = "sha256-1pnRz6ydsE1Ob46z5721S0wkfwaNw1ZMnGH4sNmmKEU=";
  };

  buildInputs = [
    acl
    libxcb-util
  ];

  nativeBuildInputs = [ makeBinaryWrapper ];

  cargoHash = "sha256-+RwS0eNYPRkab0UYLGluCRdlf2j+T7tgJGVNKOmIyVk=";

  checkFlags = [
    # requires access to /root
    "--skip tests::test_check_user_homedir"
    "--skip tests::test_a_x11_error"
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
