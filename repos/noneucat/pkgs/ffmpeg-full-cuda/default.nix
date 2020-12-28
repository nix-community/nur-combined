{ ffmpeg-full, cudatoolkit }:

(ffmpeg-full.overrideAttrs (old: {
  pname = "ffmpeg-full-cuda";
  buildInputs = old.buildInputs ++ [ cudatoolkit ];
  configureFlags = old.configureFlags ++ [
    "--enable-cuda"
    "--enable-cuvid"
    "--enable-cuda-nvcc"
  ];
})).override {
  nonfreeLicensing = true;
  nvenc = true;
}
