{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.whisper-cpp.override { cudaSupport = true; }) # CUDA acceleration keeps local transcription off the CPU.
    pkgs.whisperx
  ];
}
