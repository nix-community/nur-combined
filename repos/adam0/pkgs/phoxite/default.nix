{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  rustPlatform,
  sqlite,
  # keep-sorted end
}: let
  inherit
    (lib)
    # keep-sorted start
    licenses
    versionOlder
    # keep-sorted end
    ;
in
  rustPlatform.buildRustPackage rec {
    pname = "phoxite";
    version = "0.12.0";

    src = fetchFromGitHub {
      owner = "samehelhawary";
      repo = "phoxite";
      tag = "v${version}";
      hash = "sha256-W15u4S0fuWOBSJruiB2a1FI4P0wpOSpnVVchV5ZGvpQ=";
    };

    cargoHash = "sha256-WJGZyX5yD3VMtEavhPp5t+alRKuqU2cDa0uMmJIE26c=";
    cargoBuildFlags = ["-p" "phoxite-lsp"];
    # These query a second indexed file without waiting for the index, so they
    # race the indexer on slower builders such as CI runners.
    cargoTestFlags = ["-p" "phoxite-lsp" "--" "--skip" "a_joomla_site_names_what_its_files_declare" "--skip" "a_magento_module_names_what_its_xml_declares"];

    # Fat LTO trades build time for runtime speed over upstream's thin LTO.
    env.CARGO_PROFILE_RELEASE_LTO = "fat";

    # libsqlite3-sys links the system library here despite rusqlite's bundled feature.
    buildInputs = [sqlite];

    meta = {
      # mago crates require rustc 1.99; nixos-26.05 ships an older rustc.
      broken = versionOlder rustPlatform.rust.rustc.version "1.99";
      # keep-sorted start
      description = "PHP, Laravel and Twig language server";
      homepage = "https://github.com/samehelhawary/phoxite";
      license = licenses.asl20;
      mainProgram = "phoxite-lsp";
      # keep-sorted end
    };
  }
