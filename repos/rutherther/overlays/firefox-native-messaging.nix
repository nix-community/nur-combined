final: prev: {
  firefox = prev.firefox.override {
    extraNativeMessagingHosts = [
      prev.firefoxpwa
    ];
  };
}
