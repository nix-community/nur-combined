{
  dbus,
  fetchFromGitHub,
  lib,
  runtimeShell,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "computer-use-linux";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-D4UF1gdPcfBmgVdVquQXo8i5WGutquXgXa41Du8Pq0Q=";
  };

  cargoHash = "sha256-+Eum9F6jBsLSlqSr8E8QL1dnlCyjPe8ekPhKZqc5/+A=";

  postPatch = ''
    # Pin the opt-in host shell and shell scripts created by upstream tests.
    substituteInPlace src/server.rs src/ydotool.rs \
      --replace-fail /bin/sh ${runtimeShell}

    # The sandbox has no /etc/dbus-1/session.conf.
    substituteInPlace src/windowing/backends/kwin.rs \
      --replace-fail \
        '["--session", "--nofork", "--nopidfile", "--print-address=1"]' \
        '["--config-file=${dbus}/share/dbus-1/session.conf", "--nofork", "--nopidfile", "--print-address=1"]'

    # Keep test-only socket paths below sockaddr_un.sun_path's 107-byte limit.
    substituteInPlace src/ydotool.rs \
      --replace-fail 'computer-use-linux-ydotool-{label}' 'cu-{label}'
  '';

  # KWin tests start a private session bus; no live desktop is required.
  nativeCheckInputs = [ dbus ];

  meta = with lib; {
    description = "Control a real Linux desktop from any MCP host.";
    longDescription = ''
      Rust MCP server and CLI for Linux desktop control through AT-SPI,
      desktop portals, and compositor-specific window targeting. Installs
      computer-use-linux and the companion computer-use-linux-cosmic helper;
      the GNOME Shell extension is embedded in the main binary.

      Desktop helper commands (hyprctl, wtype, ydotool, xdotool, wmctrl,
      gdbus, ...) are resolved from PATH at runtime. Install only the tools
      your desktop needs and configure its accessibility, portals, and input
      permissions separately. Start the stdio MCP server with
      computer-use-linux mcp and inspect readiness with computer-use-linux doctor.
    '';
    homepage = "https://github.com/agent-sh/computer-use-linux";
    changelog = "https://github.com/agent-sh/computer-use-linux/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = pname;
  };
}
