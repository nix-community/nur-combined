(async () => {
  if (window.location.pathname != '/') return;
  let storage = await getDataSourceForDomain(window.location);
  let { tetrioPlusEnabled, skin, skinAnim, ghost, ghostAnim } = await storage.get([
    'tetrioPlusEnabled', 'skin', 'skinAnim', 'ghost', 'ghostAnim'
  ]);
  if (!tetrioPlusEnabled || (!skin && !skinAnim && !ghost && !ghostAnim)) return;

  let script = document.createElement('script');
  script.src = browser.runtime.getURL('source/injected/connected-skins.js');
  document.head.appendChild(script);
})().catch(console.error);
