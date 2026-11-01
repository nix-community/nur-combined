{ lib, pkgs, ... }:
let
  braveAudioReset = pkgs.writeShellApplication {
    name = "brave-audio-reset";
    runtimeInputs = with pkgs; [
      coreutils
      procps
      pulseaudio
    ];
    text = ''
      # Wait for the socket-activated server to accept clients before Brave
      # recreates its audio helper. Do not reset it if the server is unavailable.
      timeout 10s pactl info > /dev/null

      # Chromium rewrites this process's argv as a space-separated title.
      # Match only the current user's Brave audio utility, never browser tabs,
      # the main browser process, or other Chromium/Electron applications.
      pattern='^/nix/store/[^/]+/opt/brave[.]com/brave/brave --type=utility --utility-sub-type=audio[.]mojom[.]AudioService( |$)'
      if pkill --echo --signal TERM --uid "$(id -u)" --full "$pattern"; then
        echo "Reset Brave audio helper after connecting to the audio server."
      else
        status=$?
        # No running helper is normal at login or when Brave is closed.
        if [ "$status" -ne 1 ]; then
          exit "$status"
        fi
      fi
    '';
  };
in
{
  # The XPS 8940 BIOS marks the front headset microphone pin as unused.
  # Enable the verified input on 0x19 without repurposing headphone output 0x1b.
  # The Realtek quirk matches subsystem 1028:09c5 in the ALC882-family driver.
  # Test the C fixup without a firmware override masking its pin configuration.
  # https://bugs.launchpad.net/bugs/1971232
  boot.kernelPatches = [
    {
      name = "dell-xps8940-headset-mic";
      patch = ./patches/0001-ALSA-hda-realtek-XPS-8940-headset-mic.patch;
    }
  ];

  environment.systemPackages = [ braveAudioReset ];

  # Brave retains a dead PulseAudio input context after pipewire-pulse restarts,
  # including during nixos-rebuild switch. Restarting its audio utility restores
  # microphone detection without closing the browser or changing permissions.
  # https://github.com/brave/brave-browser/issues/13030
  systemd.user.services.pipewire-pulse.serviceConfig.ExecStartPost = [
    # A recovery failure must not fail the audio server itself.
    "-${lib.getExe braveAudioReset}"
  ];
}
