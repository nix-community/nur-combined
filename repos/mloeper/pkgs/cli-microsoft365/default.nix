{ lib
, stdenv
, pkgs
, fetchFromGitHub
, system ? builtins.currentSystem
, xsel
, nodejs_18
, makeWrapper
, defaultBrowserBinaryPath ? "${pkgs.firefox}/bin/firefox"
, installShellFiles
, gnugrep
, ...
}:

let
  nodejs = nodejs_18;
  nodePackages = import ./node2nix {
    inherit pkgs system nodejs;
  };
  nodeDependencies = nodePackages.nodeDependencies;
in
stdenv.mkDerivation
{
  pname = "cli-microsoft365";
  version = "7.6.0";
  src = fetchFromGitHub {
    owner = "pnp";
    repo = "cli-microsoft365";
    rev = "v7.6.0";
    hash = "sha256-0grJccby3FIL6iIZ4gXEgX5hVsdnGNMr2EwRuJXyq+4=";
  };

  nativeBuildInputs = [ makeWrapper installShellFiles ];
  buildInputs = [ nodejs ];

  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"
    npm run build
  '';

  installPhase = ''
    export PATH="${nodeDependencies}/bin:$PATH"
    mkdir -p $out/bin
   
    install -d $out/docs/docs
    cp -r dist package.json allCommands.json allCommandsFull.json csom.json $out/
    cp -r docs/docs/_clisettings.mdx docs/docs/cmd $out/docs/docs
    ln -s ${nodeDependencies}/lib/node_modules $out/node_modules

    # create cli binary
    # TODO(mloeper): create binaries for m365_chili and microsoft365
    makeWrapper ${nodejs}/bin/node $out/bin/m365 --add-flags "$out/dist/index.js" --set XDG_CURRENT_DESKTOP X-Generic --set BROWSER "${defaultBrowserBinaryPath}" --inherit-argv0 --set PATH ${lib.makeBinPath [ nodejs xsel gnugrep ]}
    makeWrapper ${nodejs}/bin/node $out/bin/m365_comp --add-flags "$out/dist/autocomplete.js" --inherit-argv0 --set PATH ${lib.makeBinPath [ nodejs ]}

    runHook postInstall
  '';

  postInstall = ''
    FAKE_HOME="$NIX_BUILD_TOP/fake-home"
    mkdir -p "$FAKE_HOME"
    mkdir -p "$NIX_BUILD_TOP/share/completions"

    SHELL=bash HOME="$FAKE_HOME" $out/bin/m365 cli completion sh setup
    
    # note: completion does not work atm... zsh does not find it and bash says 'm365_comp: command not found'
    installShellCompletion --bash --cmd m365 "$FAKE_HOME/.m365_comp/completion.sh"
    installShellCompletion --zsh --cmd m365 "$FAKE_HOME/.m365_comp/completion.sh"
  '';

  meta = with lib; {
    homepage = "https://pnp.github.io/cli-microsoft365";
    description = "CLI for Microsoft 365";
    longDescription = ''
      Using the CLI for Microsoft 365, you can manage your Microsoft 365 tenant and SharePoint Framework projects on any platform. No matter if you are on Windows, macOS or Linux, using Bash, Cmder or PowerShell, using the CLI for Microsoft 365 you can configure Microsoft 365, manage SharePoint Framework projects and build automation scripts.
    '';
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "m365";
  };
}
