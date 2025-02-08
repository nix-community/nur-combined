{
  lib,
  linux-firmware,
  git,
}:

linux-firmware.overrideAttrs (oldAttrs: {

  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
    git
  ];

  postPatch = (if oldAttrs ? postPatch then oldAttrs.postPatch else ''
  '') + ''
    ${git}/bin/git apply "${./0001-bmi260-Add-BMI260-IMU-initial-configuration-data-fil.patch}"
  '';

  meta = oldAttrs.meta // {
    description = "Linux Firmware with Bosch BMI260 IMU patch";
    maintainers = with lib.maintainers; [ Cryolitia ];
  };
})
