{ pkgs, sources, ... }: with pkgs;
stdenvNoCC.mkDerivation {
  inherit (sources.arkenfox-userjs) pname version src;

  installPhase = ''
    mkdir -p $out
    cp ./user.js $out/user.js
  '';

  meta = with lib; {
    description = "Firefox privacy, security and anti-tracking: a comprehensive user.js template for configuration and hardening";
    homepage = "https://github.com/arkenfox/user.js";
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.mit;
  };
}

