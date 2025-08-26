{
  stdenv,
  lib,
  pkgs,
  ...
}:
stdenv.mkDerivation rec {
  pname = "obsidian-style-settings";
  version = "1.0.9";

  src = let
    githubSrc = pkgs.fetchFromGitHub {
      owner = "mgmeyers";
      repo = "obsidian-style-settings";
      rev = "1.0.9";
      hash = "sha256-eNbZQ/u3mufwVX+NRJpMSk5uGVkWfW0koXKq7wg9d+I=";
    };
  in
    pkgs.runCommand "obsidian-style-settings-modified" {} ''
      cp -r ${githubSrc} $out
      chmod -R +w $out

      cp ${./package.json} $out/package.json
      cp ${./yarn.lock} $out/yarn.lock
    '';

  yarnOfflineCache = pkgs.fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-tqX09XWI3ZL9bXVdjgsAEuvfCAjnyWj5uSWGFbNApds=";
  };

  nativeBuildInputs = with pkgs; [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp main.js manifest.json $out/
      cp main.css $out/styles.css
    '';

  meta = {
    description = "Offers controls for adjusting theme, plugin, and snippet CSS variables.";
    homepage = "https://github.com/mgmeyers/obsidian-style-settings";
    changelog = "https://github.com/mgmeyers/obsidian-style-settings/releases/tag/${version}";
    license = lib.licenses.gpl3;
  };
}
