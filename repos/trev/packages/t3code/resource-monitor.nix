{
  rustPlatform,
  t3code-unwrapped,
}:

rustPlatform.buildRustPackage {
  pname = "t3code-resource-monitor";
  inherit (t3code-unwrapped) version src;

  sourceRoot = "${t3code-unwrapped.src.name}/native/resource-monitor";

  cargoHash = "sha256-QartZALjE2BxgfKcV3CJjtG6oSNE/Vcbz2ESx1UrRbk=";

  # This test compares against the host's BSD `ps` and `date` on PATH. The Darwin
  # sandbox provides neither (`date` resolves to GNU coreutils), so skip only it.
  checkFlags = [
    "--skip"
    "mac_process_identities::reports_the_same_process_group_and_start_second_as_ps"
  ];

  meta = {
    description = "Native resource diagnostics sidecar for T3 Code";
    inherit (t3code-unwrapped.meta)
      homepage
      changelog
      license
      platforms
      ;
    mainProgram = "t3-resource-monitor";
  };
}
