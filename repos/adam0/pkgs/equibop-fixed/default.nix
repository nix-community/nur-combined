{
  # keep-sorted start
  bun,
  equibop,
  fetchFromGitHub,
  runCommand,
  # keep-sorted end
}: let
  arrpcSrc = fetchFromGitHub {
    owner = "Creationsss";
    repo = "arrpc-bun";
    rev = "48210d5c6efaf2db3d941a414a948c66870bd5f7";
    hash = "sha256-tPt/1/MWYFX8tbOqONXSekPJTs9Kq5u5onS4tyJdO5k=";
  };
in
  equibop.overrideAttrs (old: {
    # Use upstream's send-recursion fix until it reaches an arRPC release.
    postConfigure =
      (old.postConfigure or "")
      + ''
        chmod u+w node_modules
        chmod -R u+w node_modules/arrpc-bun
        rm -r node_modules/arrpc-bun
        cp -R ${arrpcSrc} node_modules/arrpc-bun
      '';

    passthru =
      (old.passthru or {})
      // {
        tests =
          (old.passthru.tests or {})
          // {
            websocket =
              runCommand "equibop-arrpc-websocket-test" {
                nativeBuildInputs = [bun];
              } ''
                cp -R ${arrpcSrc} arrpc-bun
                chmod u+w arrpc-bun
                cd arrpc-bun
                cp ${./websocket.test.js} websocket.test.js
                bun test websocket.test.js
                touch "$out"
              '';
          };
      };
  })
