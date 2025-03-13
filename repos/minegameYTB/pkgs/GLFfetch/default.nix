{ 
  lib,
  stdenvNoCC, 
  substituteAll, 
  writeScriptBin, 
  fetchFromGitHub, 
  makeWrapper, 
  fastfetch, 
  coreutils, 
  gawk,
  bash, 
  glfIcon ? "GLF"  # ### Use GLF icon or GLFos icon (to change icon) (How to create an overlay with this expression ?)
}:

stdenvNoCC.mkDerivation rec {
  pname = "GLFfetch-nixos";
  version = "git-${builtins.substring 0 7 src.rev}"; ### To update version number

  src = fetchFromGitHub {
    owner = "minegameYTB";
    repo = pname;
    rev = "a0935f03d32acdeb108798f3fe9cfb18ce5413a1";
    sha256 = "sha256-fO+vko4Ef41jXReIhZv2BVPTkETpAslZUrdBhyvVO2w=";
  };

  outputs = [ "out" "assets" ];
  outputsToInstall = outputs;

  buildInputs = [ fastfetch bash coreutils gawk ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    ### Variable
    iconPath=$assets/share/${pname}/${glfIcon}.png
    
    ### Create directory and copy file from source
    mkdir -p $out/bin $assets/share/${pname}/scripts
    cp $src/challenge.jsonc $assets/share/${pname}/challenge.jsonc
    cp $src/GLF.png $assets/share/${pname}/GLF.png
    cp $src/GLFos.png $assets/share/${pname}/GLFos.png
    
    if [ -d "$src/scripts" ]; then
      cp -r $src/scripts/* $assets/share/${pname}/scripts/
    fi

    ### Replace substitution by real path (from nixpkgs hash)
    substituteInPlace $assets/share/${pname}/challenge.jsonc \
      --replace-warn @GLF-path@ "$assets/share/${pname}" \
      --replace-warn @GLFos-icon@ "$iconPath" \
      --replace-warn @shell@ "${bash}/bin/bash"

    for script in $assets/share/${pname}/scripts/*.sh; do
      substituteInPlace "$script" \
        --replace-warn @GLF-path@ "$assets/share/${pname}" \
        --replace-warn @coreutils@ "${coreutils}" \
        --replace-warn @gawk@ "${gawk}"
      chmod +x "$script"
    done

    ### Make wrapper script that pass right args to fastfetch
    makeWrapper ${fastfetch}/bin/fastfetch $out/bin/GLFfetch \
      --add-flags "--config $assets/share/${pname}/challenge.jsonc" \
      --prefix PATH : ${coreutils}/bin:${gawk}/bin
  '';
  
  meta = {
    description = "A customized neofetch config file built for the GLF Linux challenges (a fork of GLFfetch to support nix)";
    homepage = "https://github.com/Gaming-Linux-FR/GLFfetch";
    license = lib.licenses.mit;
    mainProgram = "GLFfetch";
  };

}
