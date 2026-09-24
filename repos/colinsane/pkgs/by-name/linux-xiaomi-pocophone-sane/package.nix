{
  lib,
  linux-postmarketos-qcom-sdm845,
  linux_latest,
  # linux_7_1,
  #VVV nixpkgs calls `.override` on the kernel to configure additional things, especially
  # features,
  # kernelPatches,
  # randstructSeed,
  ...
}@args:
let
  extraCallArgs = lib.removeAttrs args [
    "lib"
    "linux-postmarketos-qcom-sdm845"
    "linux_latest"
    # "linux_7_1"
  ];
in
(linux_latest.override (extraCallArgs // {
  DTB = true;
  autoModules = true;
  # preferBuiltin = true;
  enableCommonConfig = true;

  kernelPatches = let
    p = linux-postmarketos-qcom-sdm845.patches;
  in (args.kernelPatches or []) ++ [
    # p."0001-arm64-dts-qcom-sdm845-xiaomi-beryllium-Enable-ath10k"  #< FAILS APPLY (7.2)
    p."0002-.forgejo-introduce-pull-request-based-CI"
    p."0003-stalled-arm64-configs-add-sdm845-config-fragment"
    p."0004-hack-Add-back-TEXT_OFFSET-in-the-built-image"
    # p."0005-EDITME-cover-title-for-stalled-hacks"  #< empty
    p."0006-stalled-hack-drm-msm-a6xx-Fix-recovery-vs-runpm-race"
    # p."0007-stalled-drm-panel-add-Novatek-NT35596S-panel-driver"  #< FAILS BUILD (7.2)
    p."0008-stalled-backlight-qcom-wled-fix-unbalanced-enable-ir"
    # p."0009-EDITME-cover-title-for-ebbg-ft8719-fixups"  #< empty
    p."0010-drm-panel-ebbg-ft8719-Split-initialization-into-enab"
    p."0011-drm-panel-ebbg-ft8719-prepare_prev_first"
    # p."0012-SDM845-DOWNSTREAM-EDITME-cover-title-for-qcom-spmi-s"  #< empty
    p."0013-dt-bindings-input-add-Qualcomm-SPMI-haptics-driver"
    p."0014-input-add-Qualcomm-SPMI-haptics-driver"
    p."0015-arm64-dts-qcom-pmi8998-Introduce-SPMI-haptics"
    p."0016-arm64-dts-qcom-sdm845-oneplus-Add-haptics-support"
    p."0017-arm64-dts-qcom-sdm845-xiaomi-beryllium-Add-haptics-s"
    p."0018-arm64-dts-qcom-sdm845-shift-axolotl-Enable-pmi8998-h"
    # p."0019-Qualcomm-3rd-gen-fuel-gauge-support"  #< empty
    p."0020-dt-bindings-power-supply-Add-schema-for-Qualcomm-pmi"
    p."0021-power-supply-Add-driver-for-Qualcomm-PMI8998-fuel-ga"
    p."0022-arm64-dts-qcom-pmi8998-Add-fuel-gauge"
    p."0023-arm64-dts-qcom-pm660-Add-fuel-gauge"
    p."0024-arm64-dts-qcom-sdm845-xiaomi-beryllium-Enable-fuel-g"
    p."0025-arm64-dts-qcom-sdm845-shift-axolotl-Enable-fuel-gaug"
    p."0026-arm64-dts-qcom-sdm660-xiaomi-lavender-Enable-support"
    # p."0027-arm64-dts-qcom-sdm670-google-sargo-Enable-fuel-gauge"  #< FAILS APPLY (7.2)
    p."0028-stalled-wifi-ath10k-make-in-order-rx-amsdu-buffers-p"
    # p."0029-HACK-series-for-working-qdsp6"  #< empty
    p."0030-hack-ASoC-qdsp6-Add-shared-session-management-for-q6"
    p."0031-hack-ASoC-qdsp6-Add-driver-for-Q6-Multimode-Voice-Ma"
    p."0032-hack-ASoC-qdsp6-Add-driver-for-Q6-Core-Voice-Process"
    p."0033-hack-ASoC-qdsp6-Add-driver-for-Q6-Core-Voice-Stream-"
    p."0034-hack-ASoC-qdsp6-Add-voice-call-functionality-in-Q6-V"
    p."0035-hack-ASoC-dt-bindings-Add-Q6-Voice-DAI-binding"
    p."0036-hack-ASoC-qdsp6-Add-Q6-Voice-DAI-driver-v2.1"
    p."0037-hack-ASoC-qdsp6-q6voice-Add-getter-setter-for-rx-and"
    p."0038-hack-ASoC-qdsp6-q6voice-dai-Add-controls-for-voice-r"
    p."0039-hack-ASoC-qdsp6-q6voice-dai-Add-VoiceMMode1-DAI"
    p."0040-hack-ASoC-qdsp6-q6voice-dai-Add-controls-for-SLIMBUS"
    p."0041-hack-ASoC-qcom-qdsp6-q6voice-dai-implement-all-slimb"
    p."0042-hack-ASoC-dt-bindings-qcom-q6dsp-add-internal-mi2s-s"
    p."0043-hack-ASoC-qdsp6-q6dsp-lpass-ports-add-internal-mi2s-"
    p."0044-hack-ASoC-qdsp6-q6afe-add-internal-mi2s-support"
    p."0045-hack-ASoC-qdsp6-q6afe-dai-add-internal-mi2s-support"
    p."0046-hack-ASoC-qdsp6-q6routing-add-internal-mi2s-support"
    p."0047-hack-ASoC-qdsp6-q6afe-pass-tdm-ctrl_sync_data_delay-"
    p."0048-hack-ASoC-qdsp6-q6afe-dai-configure-tdm-data-delay-f"
    p."0049-hack-ASoC-qdsp6-q6core-add-support-for-registering-t"
    p."0050-hack-ASoC-qdsp6-q6cvp-add-commands-in-cvd-2.3"
    p."0051-hack-ASoC-qdsp6-q6voice-add-cvd-2.3-initialization-s"
    p."0052-hack-ASoC-qdsp6-q6cvp-add-topology-ID-parameters-to-"
    p."0053-hack-ASoC-qdsp6-q6voice-pass-new-topology-property-t"
    p."0054-hack-ASoC-qdsp6-q6voice-dai-add-ALSA-controls-for-th"
    p."0055-hack-ASoC-qdsp6-q6voice-dai-add-internal-mi2s"
    p."0056-hack-ASoC-qdsp6-q6voice-dai-add-tdm"
    # p."0057-hack-ASoC-qcom-qdsp6-q6asm-dai-Keep-stream-marked-ru"  #< empty
    p."0058-hack-arm64-dts-qcom-sdm845-Add-q6voice-APR-service-d"
    p."0059-hack-arm64-dts-xiaomi-beryllium-common-Add-nodes-for"
    p."0060-hack-arm64-dts-qcom-sdm845-oneplus-common-add-nodes-"
    p."0061-hack-arm64-dts-qcom-sdm845-shift-axolotl-add-nodes-f"
    # p."0062-END-HACK-series-for-working-qdsp6"  #< empty
    p."0063-stalled-arm64-dts-qcom-sdm845-xiaomi-beryllium-add-s"
    p."0064-stalled-ASoC-codecs-wcd934x-fix-unbalanced-micbias-e"
    # p."0065-EDITME-cover-title-for-axolotl-misc"
    p."0066-arm64-dts-qcom-sdm845-shift-axolotl-Enable-sound-sub"
    p."0067-stalled-arm64-qcom-sdm845-shift-axolotl-Improve-audi"
    p."0068-stalled-ASoC-qcom-sdm845-set-codec-dai-and-component"
    p."0069-stalled-ASoC-codecs-cs35l36-include-SND_SOC_DAIFMT_D"
    p."0070-stalled-ASoC-codecs-cs35l36-add-dummy-.set_tdm_slot"
    # p."0071-EDITME-cover-title-for-placeholders"  #< empty
    p."0072-arm64-dts-qcom-sdm845-Enable-known-blocks-and-add-pl"
    # p."0073-EDITME-downstream-cameras"  #< empty
    p."0074-stalled-media-i2c-Add-imx363-image-sensor-driver"
    p."0075-stalled-media-i2c-Add-imx371-image-sensor-driver"
    p."0076-stalled-media-i2c-Add-imx376-image-sensor-driver"
    p."0077-stalled-media-i2c-Add-imx519-image-sensor-driver"
    # p."0078-EDITME-cover-title-for-shift6-camera"  #< empty
    # p."0079-arm64-dts-qcom-sdm845-shift-axolotl-Introduce-camera"  #< FAILS APPLY (7.2)
    p."0080-arm64-dts-qcom-sdm845-xiaomi-beryllium-add-support-f"
    p."0081-stalled-arm64-dts-qcom-sdm845-oneplus-camera-bringup"
    p."0082-stalled-arm64-dts-qcom-sdm845-shift-axolotl-Add-q6vo"
    p."0083-stalled-arm64-dts-qcom-sdm845-xiaomi-beryllium-Add-q"
    p."0084-stalled-arm64-dts-qcom-sdm845-oneplus-Add-q6voicedai"
    # p."0085-NFC-support-for-five-Qualcomm-SDM845-phones"  #< empty
    p."0086-arm64-dts-qcom-sdm845-oneplus-Enable-NFC"
    # p."0087-arm64-dts-qcom-sdm845-shift-axolotl-Correct-touchscr"  #< FAILS APPLY (7.1)
    # p."0088-arm64-dts-qcom-sdm845-shift-axolotl-Enable-NFC"  #< FAILS APPLY (7.2)
    # p."0089-arm64-dts-qcom-sdm845-google-common-Enable-NFC"  #< FAILS APPLY (7.2)
    # p."0090-Input-synaptics-rmi4-add-quirks-for-third-party-touc"  #< empty
    p."0091-dt-bindings-input-syna-rmi4-Document-syna-rmi4-s3706"
    # p."0092-Input-synaptics-rmi4-handle-duplicate-unknown-PDT-en"  #< FAILS APPLY (7.2)
    # p."0093-Input-synaptics-rmi4-f12-use-hardcoded-values-for-af"  #< FAILS APPLY (7.2)
    p."0094-Input-synaptics-rmi4-f55-handle-zero-electrode-count"
    p."0095-Input-synaptics-rmi4-don-t-do-unaligned-reads-in-IRQ"
    p."0096-Input-synaptics-rmi4-read-product-ID-on-aftermarket-"
    # p."0097-Input-synaptics-rmi4-support-fallback-values-for-PDT"  #< FAILS APPLY (7.2)
    # p."0098-power-supply-pmi8998-charger-improvements-and-smb5-s"  #< empty
    p."0099-dt-bindings-power-supply-qcom-pmi89980-charger-add-p"
    p."0100-power-supply-qcom_smbx-respect-battery-charge-term-c"
    p."0101-power-supply-qcom_smbx-bump-up-the-max-current"
    p."0102-power-supply-qcom_smbx-remove-unused-registers"
    p."0103-power-supply-qcom_smbx-add-smb5-support"
    p."0104-power-supply-qcom_smbx-program-aicl-rerun-time"
    # p."0105-xiaomi-perseus-support"  #< empty
    # p."0106-stalled-drm-panel-Add-support-for-Samsung-EA8076"  <# FAILS BUILD (7.2)
    # p."0107-arm64-dts-qcom-Introduce-support-for-Xiaomi-Mi-Mix-3"  #< FAILS APPLY (7.2)
    # p."0108-media-i2c-lc898217xc-initial-driver"  #< empty
    p."0109-media-dt-bindings-Add-LC898217XC-documentation"
    p."0110-media-i2c-Add-driver-for-LC898217XC-VCM"
    p."0111-MAINTAINERS-Add-entry-for-Onsemi-LC898217XC-lens-voi"
    # p."0112-EDITME-cover-title-for-rpmsg-qcom-glink"  #< empty
    p."0113-rpmsg-qcom-glink-support-waking-up-on-channel-rx"
    # p."0114-Add-framebuffer-on-Xiaomi-Poco-F1-and-disable-the-MD"  #< empty
    # p."0115-arm64-dts-qcom-sdm845-xiaomi-beryllium-Introduce-fra"  #< FAILS APPLY (7.2)
    # p."0116-arm64-dts-qcom-sdm845-oneplus-Drop-address-from-fram"  #< FAILS APPLY (7.1)
    # p."0117-arm64-dts-qcom-sdm845-shift-axolotl-Convert-fb-to-us"  #< FAILS APPLY (7.2)
    # p."0118-arm64-dts-qcom-sdm845-samsung-starqltechn-Convert-fb"  #< FAILS APPLY (7.2)
    p."0119-arm64-dts-qcom-sdm845-xiaomi-beryllium-tianma-Disabl"
    p."0120-arm64-dts-qcom-sdm845-google-Enable-fuel-gauge"
    p."0121-arm64-dts-qcom-sdm845-oneplus-add-rear-camera-actuat"
    # p."0122-Input-support-for-STM-FTS5"  #< empty
    # p."0123-Input-stmfts-Fix-the-MODULE_LICENSE-string"  #< FAILS APPLY (7.2)
    # p."0124-Input-stmfts-Use-dev-struct-directly"  #< FAILS APPLY (7.2)
    # p."0125-Input-stmfts-Switch-to-devm_regulator_bulk_get_const"  #< FAILS APPLY (7.2)
    # p."0126-Input-stmfts-abstract-reading-information-from-the-f"  #< FAILS APPLY (7.2)
    # p."0127-Input-stmfts-disable-regulators-when-power-on-fails"  #< FAILS APPLY (7.2)
    # p."0128-Input-stmfts-use-client-to-make-future-code-cleaner"  #< FAILS APPLY (7.2)
    # p."0129-dt-bindings-input-touchscreen-st-stmfts-Introduce-re"  #< FAILS APPLY (7.2)
    # p."0130-Input-stmfts-add-optional-reset-GPIO-support"  #< FAILS APPLY (7.2)
    p."0131-dt-bindings-input-touchscreen-st-stmfts-Introduce-ST"
    # p."0132-Input-stmfts-support-FTS5"  #< FAILS APPLY (7.2)
    p."0133-arm64-dts-qcom-sdm845-google-Add-STM-FTS-touchscreen"
    # p."0134-Add-initial-dual-front-camera-and-rear-flash-support"  #< empty
    p."0135-arm64-dts-qcom-sdm845-google-Add-dual-front-IMX355-c"
    p."0136-arm64-dts-qcom-sdm845-google-Enable-PMI8998-camera-f"
    # p."0137-EDITME-cover-title-for-tfa98xx"  #< empty
    p."0138-wip-ASoC-codecs-add-support-for-TFA98xx-based-on-dow"
    p."0139-downstream-arm64-dts-qcom-sdm845-oneplus-fajita-enab"
    # p."0140-EDITME-cover-title-for-axolotl-wifi"  #< empty
    # p."0141-arm64-dts-qcom-sdm845-shift-axolotl-describe-WiFi-BT"  #< FAILS APPLY (7.2)
    # p."0142-latest-hot-fixes-separator"  #< empty
    p."0143-hack-arm64-dts-qcom-sdm845-disable-qcrypto"
    p."0144-hack-scripts-allow-unused-command-line-arguments-wit"
    p."0145-drm-panel-visionox-rm69299-Set-prepare_prev_first"
    p."0146-sdm845.config-Load-shift6mq-panel-as-module"
    # p."0147-Correct-Xiaomi-Poco-F1-compatible-strings-and-evalua"  #< empty
    # p."0148-dt-bindings-arm-qcom-Add-Xiaomi-Poco-F1-Tianma-varia"  #< FAILS APPLY (7.2)
    # p."0149-arm64-dts-qcom-sdm845-xiaomi-beryllium-Fix-compatibl"  #< FAILS APPLY (7.2)
    # p."0150-media-camss-Add-support-for-C-PHY-configuration-on-Q"  #< empty
    p."0151-media-qcom-camss-csiphy-Introduce-PHY-configuration"
    # p."0152-media-qcom-camss-csiphy-3ph-Use-odd-bits-for-configu"  #< FAILS BUILD (7.2)
    # p."0153-media-qcom-camss-Prepare-CSID-for-C-PHY-support"  #< FAILS APPLY (7.2)
    # p."0154-media-qcom-camss-Initialize-lanes-after-lane-configu"  #< FAILS APPLY (7.2)
    # p."0155-media-qcom-camss-csiphy-3ph-Add-Gen2-v1.1-MIPI-CSI-2"  #< FAILS APPLY (7.2)
    # p."0156-media-qcom-camss-csiphy-3ph-Add-Gen2-v1.2.1-MIPI-CSI"  #< FAILS APPLY (7.2)
    # p."0157-media-qcom-camss-csiphy-3ph-C-PHY-needs-own-lane-con"  #< FAILS BUILD (7.2)
    # p."0158-media-qcom-camss-Account-for-C-PHY-when-calculating-"  #< FAILS BUILD (7.2)
    p."0159-soc-qcom-qmi-Fix-invalid-data-length-in-encoder"
    p."0160-soc-qcom-qmi-Avoid-splatting-the-length-destination-"
    p."0161-hack-clk-qcom-rcg2-msm-dsi-Fix-hangs-caused-by-regis"
    # p."0162-arm64-dts-qcom-sdm845-shift-axolotl-Add-actuator-for"  #< FAILS APPLY (7.2)
    p."0163-HACK-arm64-dts-qcom-xiaomi-beryllium-enable-serial-d"
    # p."0164-arm64-dts-qcom-sdm845-xiaomi-beryllium-common-update"  #< FAILS APPLY (7.1)
    p."0165-drm-panel-nt36672a-move-dsi-commands-from-prepare-un"
    p."0166-HACK-clk-qcom-dispcc-sdm845-set-GENPD_FLAG_NO_STAY_O"
    p."0167-ASoC-codecs-tas2559-Add-initial-tas2559-audio-amplif"
    p."0168-arm64-dts-qcom-sdm845-xiaomi-beryllium-common-add-su"
    p."0169-ASoC-codecs-Add-support-for-TAS2557-codec"
    p."0170-Revert-arm64-dts-qcom-sdm845-xiaomi-beryllium-tianma"
    p."0171-MAINTAINERS-Add-entry-for-ROHM-BU64748-lens-voice-co"
    p."0172-media-dt-bindings-Add-ROHM-BU64748-documentation"
    p."0173-media-i2c-Add-driver-for-ROHM-BU64748"
    p."0174-arm64-dts-qcom-sdm845-xiaomi-beryllium-add-rear-came"
    p."0175-sdm845.config-enable-ROHM-BU64748-camera-lens-actuat"
    p."0176-sdm845.config-align-with-pmOS-kconfig-check"
    p."0177-ASoC-codecs-add-support-for-MAX98512-based-on-downst"
    p."0178-arm64-dts-qcom-sdm845-starqltechn-improve-support"
    p."0179-arm64-dts-qcom-sdm845-starqltechn-fix-slpi-support"
    p."0180-sdm845.config-split-into-misc.config-pmos.config-and"
    p."0181-drm-panel-sw43408-move-dsi-commands-into-enable-and-"
    p."0182-HACK-drm-panel-sw43408-skip-unprepare"
    p."0183-arm64-dts-qcom-sdm845-google-common-add-audio-suppor"
    p."0184-arm64-dts-qcom-sdm845-google-common-fix-camera-clock"
    # p."0185-arm64-dts-qcom-sdm845-lg-common-Add-camera-flash"  #< FAILS APPLY (7.2)
    # p."0186-arm64-dts-qcom-sdm845-lg-common-Change-ipa-gsi-loade"  #< FAILS APPLY (7.2)
    # p."0187-arm64-dts-qcom-sdm845-lg-judyln-judyp-Reference-memo"  #< FAILS APPLY (7.2)
    # p."0188-arm64-dts-qcom-sdm845-lg-Enable-qcom-snoc-host-cap-s"  #< FAILS APPLY (7.2)
    # p."0189-drm-panel-Add-LG-LH609QH1-Panel-with-SW49410-control"  #vv
    # p."0190-input-touchscreen-sw49410-ts-spi-Add-driver-for-SW49"  #  these apply but FAILS BUILD (7.2)
    # p."0191-arm64-dts-qcom-sdm845-lg-judyln-add-fuel-gauge"        #^^
    p."0192-arm64-dts-qcom-sdm845-lg-common-Enable-NFC"
    p."0193-sdm845.config-Drivers-for-LG-G7-ThinQ"
    p."0194-sdm845.config-further-cleanup-and-some-moved-into-mi"
  ];

})) // {
  inherit extraCallArgs;
}
