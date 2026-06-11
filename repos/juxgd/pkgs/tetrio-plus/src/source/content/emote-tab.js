/* Added by Jabster28 | MIT Licensed */
/* Modified by UniQMG */
(async () => {
  if (window.location.pathname != '/') return;
  let storage = await getDataSourceForDomain(window.location);
  let { tetrioPlusEnabled } = await storage.get('tetrioPlusEnabled');
  if (!tetrioPlusEnabled) return;
  let res = await storage.get('enableEmoteTab');
  if (!res.enableEmoteTab) return;

  let url = `https://ch.tetr.io/api/users/${localStorage.tetrio_userID}`;
  localStorage.chTetrioUser = await fetch(url)
    .then(r => r.json())
    .then(d => ({
      sysop: d.data.role == 'sysop', // osk only, I assume
      staff: d.data.role == 'sysop' || d.data.role == 'admin' || d.data.role == 'mod',
      supporter: d.data.supporter
    }))
    .catch(ex => {
      console.warn('Failed to fetch usable emotes', ex);
      return { supporter: true, staff: true, sysop: true };
    })
    .then(val => JSON.stringify(val));

  let script = document.createElement('script');
  script.src = browser.runtime.getURL('source/injected/emote-tab.js');
  document.head.appendChild(script);
})().catch(console.error);
