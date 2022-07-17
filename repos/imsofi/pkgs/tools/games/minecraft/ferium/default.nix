{ stdenv
, fetchFromGitHub
, rustc
, cargo 
, rustPlatform
, pkg-config
, installShellFiles
, lib
}:

rustPlatform.buildRustPackage rec {
  pname = "ferium";
  version = "4.1.7";

  src = fetchFromGitHub {
    owner = "gorilla-devs";
    repo = pname;
    rev = "a5f73f2b1e7d23209299e5809c680404b6186e82";
    sha256 = "sha256-yMisldaHkjSf1v9gkNYMsF+0j5fhrDAyCUQBjFi6XjM=";
  };

  patches = [ ./0001-Remove-std-process-ExitCode.patch ];

  cargoSha256 = "sha256-DZmt5ggBSJAFjOG/IfkXIACVUSDRFT81/jyFYkoCiJI=";

  # Do not build the gui part of the package.
  buildNoDefaultFeatures = true;

  # Tests are highly impure, accessing several websites.
  # Assuming upstream ensures all tests run correctly before
  # tagging a release.
  doCheck = false;

  # Sanity check that the compiled binary actually runs
  # without any errors.
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/ferium --help > /dev/null
  '';

  nativeBuildInputs = [ pkg-config installShellFiles ];

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/ferium complete $shell > ferium.$shell
      installShellCompletion ferium.$shell
    done
  '';

  meta = with lib; {
    description = "A CLI minecraft mod manager";
    homepage = "https://github.com/theRookieCoder/ferium";
    license = licenses.mpl20;
    maintainers = with maintainers; [ imsofi ];
    platforms = platforms.linux;
  };
}
