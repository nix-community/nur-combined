{ lib
, stdenv
, pkgs
, fetchFromGitHub
, system ? builtins.currentSystem
, xsel
, nodejs_18
, makeWrapper
, defaultBrowserBinaryPath ? "${pkgs.firefox}/bin/firefox"
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

  buildInputs = [ nodejs makeWrapper ];

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
    makeWrapper ${nodejs}/bin/node $out/bin/m365 --add-flags "$out/dist/index.js" --set BROWSER "${defaultBrowserBinaryPath}" --inherit-argv0 --set PATH ${lib.makeBinPath [ nodejs xsel ]}
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
    aliases = [ "m365" ];
  };
}
