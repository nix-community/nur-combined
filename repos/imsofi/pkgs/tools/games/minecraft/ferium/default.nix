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
  version = "4.1.4";

  src = fetchFromGitHub {
    owner = "gorilla-devs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Xf1Mi6pst9A2R6gL6QR7z9dxeYPGAttUsGHfj+L8uFU=";
  };

  patches = [ ./0001-Remove-std-process-ExitCode.patch ];

  cargoSha256 = "sha256-cid9r/YIXcRu9TvptZSat0Fa3FJ8c133cut3LB365sQ=";

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

  # Due to the stateful nature of ferium, all commands require the config.json
  # file being complete with at least one minecraft profile inside it.
  # To be able to build the autocompletion with the included commands im adding in
  # a minimal config.json to be able to run the command.
  # It also requires read-write on the file, so i move it into the install process
  # as well.
  postInstall = ''
    cp ${./config.json} config.json
    chmod 0644 config.json

    for shell in bash fish zsh; do
      $out/bin/ferium --config-file=config.json complete $shell > ferium.$shell
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
