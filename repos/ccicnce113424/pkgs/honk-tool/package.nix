{
  lib,
  rustPlatform,
  honk-core,
  cmake,
  gitMinimal,
  iproute2,
  makeWrapper,
  ninja,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "honk-tool";
  # Same workspace and release as honk-core; reuse its source and vendored
  # dependencies instead of duplicating fetch details here.
  inherit (honk-core) version src cargoDeps;

  __structuredAttrs = true;
  strictDeps = true;

  cargoBuildFlags = [
    "--package"
    "honk-tool"
  ];

  # honk-core's build script stamps the release tag into honk_core::VERSION,
  # which honk-tool's clap definition uses.
  env.GITHUB_REF = "refs/tags/debug.${finalAttrs.version}";

  # honk-tool links honk-outbound, whose boring-sys builds BoringSSL through
  # cmake; ninja beats the default generator at the default job count, as in
  # honk-core.
  nativeBuildInputs = [
    cmake
    gitMinimal
    makeWrapper
    ninja
    rustPlatform.bindgenHook
  ];
  env.CMAKE_GENERATOR = "Ninja";
  dontUseNinjaBuild = true;
  dontUseNinjaCheck = true;
  dontUseNinjaInstall = true;

  stripAllList = [ "bin" ];

  # `diagnose` shells out to `ip netns exec`; keep iproute2 on the tool's
  # PATH so that subcommand works in a bare environment. The module adds the
  # deployment-specific DAE_LOCATION_ASSET on top of this wrapper.
  postFixup = ''
    wrapProgram $out/bin/honk-tool \
      --prefix PATH : "${lib.makeBinPath [ iproute2 ]}"
  '';

  # Upstream's suite expects a live engine, network access and root.
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  # version, src and cargoDeps follow honk-core's update unit.
  passthru.updateScript = null;

  meta = {
    description = "CLI toolbox for honk: subscription checks, datapath diagnostics and geo database search";
    homepage = "https://github.com/Glassyiris/honk";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "honk-tool";
    platforms = lib.platforms.linux;
  };
})
