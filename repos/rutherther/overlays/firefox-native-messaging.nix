final: prev: {
  firefox = prev.firefox.override {
    nativeMessagingHosts = [
      prev.firefoxpwa-unwrapped
    ];
  };
}
