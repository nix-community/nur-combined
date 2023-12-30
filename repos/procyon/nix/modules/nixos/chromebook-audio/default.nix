# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [ alsa-ucm-conf ];
    sessionVariables.ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf}/share/alsa/ucm2";
  };

  nixpkgs.overlays = with pkgs; [
    (final: prev:
      {
        alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs (old: {
          wttsrc = (fetchFromGitHub {
            owner = "WeirdTreeThing";
            repo = "chromebook-ucm-conf";
            rev = "484f5c581ac45c4ee6cfaf62bdecedfa44353424";
            hash = "sha256-Jal+VfxrPSAPg9ZR+e3QCy4jgSWT4sSShxICKTGJvAI=";
          });

          installPhase = ''
            runHook preInstall
            mkdir -p $out/share/alsa
            cp -r ucm ucm2 $out/share/alsa
            mkdir -p $out/share/alsa/ucm2/conf.d
            cp -r $wttsrc/{hdmi,dmic}-common $wttsrc/tgl/* $out/share/alsa/ucm2/conf.d
            runHook postInstall
          '';
        });
      })
  ];
}
