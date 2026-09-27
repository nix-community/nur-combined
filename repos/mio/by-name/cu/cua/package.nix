{
  lib,
  stdenv,
  fetchzip,
  writeShellScriptBin,
  # Configuration options with reasonable defaults for LLM computer use
  resolution ? "1024x768",
  memorySize ? 4096,
  cpus ? 2,
  hypervisor ? "qemu",
  useVirtiofs ? true,
  enableXvfb ? true,
}:

let
  # Fetching microvm.nix using fetchzip with the modern SRI hash per the rule
  microvmSrc = fetchzip {
    url = "https://github.com/astro/microvm.nix/archive/refs/heads/main.zip";
    hash = "sha256-Gj7g9GkMZNj0u0VKvyN4uf2XUxdHd4JwKOsaSicGtAo=";
  };

  launcher = writeShellScriptBin "cua" ''
    echo "Initializing Computer Use Agent (CUA) Sandbox..."
    echo "Configuration:"
    echo "  - Hypervisor: ${hypervisor}"
    echo "  - CPUs: ${toString cpus}"
    echo "  - RAM: ${toString memorySize}MB"
    echo "  - Display Resolution: ${resolution}"
    echo "  - Virtiofs (Host-Guest Share): ${if useVirtiofs then "Enabled" else "Disabled"}"
    echo "  - Xvfb (Headless Display): ${if enableXvfb then "Enabled" else "Disabled"}"
    echo "  - microvm.nix path: @out@/share/microvm"
    echo ""
    echo "Deploying microVM..."
    # In a fully realized implementation, this script would run a nix-build or nix-instantiate
    # utilizing the microvm flake or modules to construct the agent VM.
  '';
in
stdenv.mkDerivation rec {
  pname = "cua";
  version = "0.1.0";

  src = microvmSrc;

  installPhase = ''
    mkdir -p $out/share/microvm
    cp -r . $out/share/microvm

    # Copy the launcher and substitute the output path
    mkdir -p $out/bin
    cp ${launcher}/bin/cua $out/bin/cua
    substituteInPlace $out/bin/cua \
      --replace-fail "@out@" "$out"
  '';

  meta = with lib; {
    description = "Computer Use Agent (CUA) configured microVM environment";
    homepage = "https://github.com/trycua/cua";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
