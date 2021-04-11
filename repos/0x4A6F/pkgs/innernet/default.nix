{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, llvmPackages
, darwin
, sqlite
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "innernet";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "tonarino";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-OomCSA02ypFVzkYMcmkFREWB6x7oxgpt7x2zRANIDMw=";
  };
  cargoSha256 = "sha256-xNw3IMnWKMlOijohurLoaYmSnqY/+doTm9wDIl5AMxc=";

  nativeBuildInputs = with llvmPackages; [
    llvm
    clang
    installShellFiles
  ];
  buildInputs = [
    sqlite
  ] ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  LIBCLANG_PATH = "${llvmPackages.libclang}/lib";

  postInstall = ''
    installManPage doc/innernet-server.8.gz
    installManPage doc/innernet.8.gz
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    if [[ "$("$out/bin/${pname}"-server --version)" == "${pname}-server ${version}" ]]; then
      echo '${pname}-server smoke check passed'
    else
      echo '${pname}-server smoke check failed'
      return 1
    fi
    if [[ "$("$out/bin/${pname}" --version)" == "${pname} ${version}" ]]; then
      echo '${pname} smoke check passed'
    else
      echo '${pname} smoke check failed'
      return 1
    fi
  '';

  meta = with lib; {
    description = "A private network system that uses WireGuard under the hood";
    homepage = "https://github.com/tonarino/innernet";
    license = licenses.mit;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.all;
  };
}
