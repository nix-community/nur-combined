# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }: {
  console.keyMap = "us-acentos";

  time.timeZone = "America/Sao_Paulo";

  services.xserver = {
    layout = "us";
    xkbVariant = "intl";
  };

  networking.timeServers = lib.mkDefault [
    "pool.ntp.br"
    "pool.ntp.org"
  ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc libpinyin hangul anthy ];
    };
    supportedLocales = [
      "ko_KR.UTF-8/UTF-8" # Korean
      "ja_JP.UTF-8/UTF-8" # Japanese
      "en_US.UTF-8/UTF-8" # American English
      "es_ES.UTF-8/UTF-8" # European Spanish
      "zh_CN.UTF-8/UTF-8" # Simplified Chinese
      "pt_BR.UTF-8/UTF-8" # Brazilian Portuguese
    ];
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
}
