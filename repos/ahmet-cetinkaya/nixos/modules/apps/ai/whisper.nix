{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.whisper-cpp.override {cudaSupport = true;}) # CUDA acceleration keeps local transcription off the CPU.
    pkgs.whisperx
    pkgs.dikte-bin # Local voice dictation that pastes Turkish transcripts into terminal agents.
  ];

  # Dikte pastes transcripts by sending keystrokes through ydotoold's uinput
  # socket, and its native paste helper opens /dev/uinput directly;
  # programs.ydotool alone does not load the module or write the udev rule.
  programs.ydotool.enable = true;
  hardware.uinput.enable = true;
  users.users.ac.extraGroups = [ "ydotool" "uinput" ];
}
