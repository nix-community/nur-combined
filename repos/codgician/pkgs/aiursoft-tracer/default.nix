{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  buildNpmPackage,
  curl,
  fetchFromGitHub,
  procps,
  runCommand,
  ...
}:

let
  pname = "aiursoft-tracer";
  src = fetchFromGitHub {
    owner = "AiursoftWeb";
    repo = "Tracer";
    rev = "b04b7af5cb45ad8a707c1525e7b2b349e0d6f109";
    hash = "sha256-uflAejOLtI5pB3w5CEVoJE/kbCXoZhf8pFla2iJNRys=";
  };

  version = "0-unstable-2026-07-14";

  wwwroot = buildNpmPackage {
    pname = "${pname}-wwwroot";
    src = "${src}/src/Aiursoft.Tracer/wwwroot";
    inherit version;
    npmDepsHash = "sha256-Gf53euGKcC0LQ6I1pCo+t6tXnuqv9bfFPYhz0lcNBSM=";
    dontNpmBuild = true;

    # The upstream lockfile pins some packages to Aiursoft's private npm
    # registry, which is unreliable (Cloudflare 525 errors). Fetch them from
    # the official registry instead; the tarballs are byte-identical.
    postPatch = ''
      substituteInPlace package-lock.json \
        --replace-fail "https://npm.aiursoft.com/" "https://registry.npmjs.org/"
    '';

    installPhase = ''
      mkdir -p $out
      cp -r * $out
    '';
  };
in
let
  package = buildDotnetModule {
    inherit
      pname
      src
      version
      wwwroot
      ;

    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
    nugetDeps = ./deps.json;

    projectFile = "Aiursoft.Tracer.sln";
    enableParallelBuilding = false;

    postFixup = ''
      # Keep upstream's configuration beside the executable and replace only the
      # mutable paths at runtime.
      rm -rf $out/lib/${pname}/wwwroot
      ln -s ${wwwroot} $out/lib/${pname}/wwwroot

      # Run from the published application directory so appsettings.json is
      # discovered, while persisting mutable data outside the Nix store.
      dir=$out/lib/${pname}
      sedexpr='s|\(exec.*Aiursoft\.Tracer.*\)|(cd '
      sedexpr+="$dir"
      sedexpr+=' \&\& dataDir="''${XDG_DATA_HOME:-$HOME/.local/share}/aiursoft-tracer" \&\& mkdir -p "$dataDir" \&\& ConnectionStrings__DefaultConnection="''${ConnectionStrings__DefaultConnection:-Data Source=$dataDir/app.db;Cache=Shared}" Storage__Path="''${Storage__Path:-$dataDir/data}" \1)|g'
      sed -i -e "$sedexpr" $out/bin/Aiursoft.Tracer
    '';

    passthru = {
      updateScript = ./update.sh;
      tests.smoke =
        runCommand "${pname}-smoke"
          {
            nativeBuildInputs = [
              curl
              procps
            ];
          }
          ''
            export HOME="$TMPDIR/home"
            export XDG_DATA_HOME="$TMPDIR/data"
            export ASPNETCORE_URLS=http://127.0.0.1:18080
            mkdir -p "$HOME" "$XDG_DATA_HOME"

            ${lib.getExe package} --urls "$ASPNETCORE_URLS" > "$TMPDIR/server.log" 2>&1 &
            server_pid=$!
            cleanup() {
              pkill -TERM -P "$server_pid" 2>/dev/null || true
              kill "$server_pid" 2>/dev/null || true
              wait "$server_pid" 2>/dev/null || true
            }
            trap cleanup EXIT

            for _ in $(seq 1 30); do
              if curl --fail --silent "$ASPNETCORE_URLS"/ > /dev/null; then
                touch "$out"
                exit 0
              fi
              if ! kill -0 "$server_pid" 2>/dev/null; then
                cat "$TMPDIR/server.log" >&2
                exit 1
              fi
              sleep 1
            done
            cat "$TMPDIR/server.log" >&2
            exit 1
          '';
    };

    meta = with lib; {
      homepage = "https://tracer.aiursoft.com";
      description = "Tracer is a simple network speed test app.";
      license = licenses.mit;
      platforms = platforms.linux;
      mainProgram = "Aiursoft.Tracer";
    };
  };
in
package
