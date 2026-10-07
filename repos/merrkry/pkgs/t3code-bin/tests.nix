{
  lib,
  runCommand,
  bash,
  coreutils,
  python3,
  t3code,
}:

{
  pty = runCommand "t3code-desktop-pty-smoke" { } ''
    ${coreutils}/bin/timeout 60s env ELECTRON_RUN_AS_NODE=1 \
      ${lib.getExe t3code.desktop} -e '
        const assert = require("node:assert/strict");
        const pty = require("${t3code.desktop.unwrapped}/libexec/t3code/resources/app.asar.unpacked/node_modules/node-pty");
        const deadline = setTimeout(() => { throw new Error("PTY did not exit"); }, 30000);
        const terminal = pty.spawn("${lib.getExe bash}", [
          "--noprofile", "--norc", "-c", "printf pty-ok",
        ], { env: process.env });
        let output = "";
        terminal.onData((data) => { output += data; });
        terminal.onExit(({ exitCode }) => {
          clearTimeout(deadline);
          assert.equal(exitCode, 0);
          assert.equal(output, "pty-ok");
        });
      '
    touch "$out"
  '';

  web = runCommand "t3code-web-startup-smoke" { T3CODE_TELEMETRY_ENABLED = "false"; } ''
    # The build's default HOME is not writable; the server needs a data directory.
    export HOME="$TMPDIR"
    export T3CODE_HOME="$HOME/.t3"
    ${python3}/bin/python ${./web-smoke.py} ${lib.getExe t3code}
    touch "$out"
  '';
}
