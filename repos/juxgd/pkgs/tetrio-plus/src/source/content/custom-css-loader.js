(async () => {
  let storage = await getDataSourceForDomain(window.location);
  let res = await storage.get([
    'customCss',
    'enableCustomCss',
    'tetrioPlusEnabled',
  ]);
  if (!res.tetrioPlusEnabled || !res.enableCustomCss || !res.customCss) return;
  let style = document.createElement('style');
  style.appendChild(document.createTextNode(res.customCss));
  document.head.appendChild(style);
})();
