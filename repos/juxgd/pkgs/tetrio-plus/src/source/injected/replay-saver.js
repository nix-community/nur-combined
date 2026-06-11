(async () => {
  let wasLastVictoryScreenVisible = false;
  let observer = new MutationObserver(() => {
    const isVisible = !document.getElementById("victoryview").classList.contains("hidden");
    console.log("[TETR.IO PLUS DEBUG] observed mutation", isVisible, wasLastVictoryScreenVisible);

    if (!isVisible) {
      wasLastVictoryScreenVisible = false;
      return;
    }

    if (isVisible && !wasLastVictoryScreenVisible) {
      wasLastVictoryScreenVisible = true;

      let originalAppendChild = document.body.appendChild;
      document.body.appendChild = async function(...args) {
        console.log("[TETR.IO PLUS DEBUG] Intercepted appendChild", args);
        if (args[0].download == 'replay.ttrm') {
          args[0].click = () => console.log('[TETR.IO PLUS] cancelled download click');
          document.body.appendChild = originalAppendChild;

          let url = args[0].href;
          let intercepted = await fetch(url).then(res => res.text());

          window.dispatchEvent(new CustomEvent(`tetrio-plus-intercepted-replay`, {
            detail: intercepted
          }));
        }
        originalAppendChild.apply(document.body, args);
      }

      document.getElementById("victory_downloadreplay").click();
    }
  });

  while (!document.getElementById("victoryview"))
    await new Promise(res => setTimeout(res, 10));

  console.log("[TETR.IO PLUS DEBUG] Enabling #victoryview observer");
  observer.observe(document.getElementById("victoryview"), {
    attributes: true,
    attributeFilter: ["class"]
  });
})()
