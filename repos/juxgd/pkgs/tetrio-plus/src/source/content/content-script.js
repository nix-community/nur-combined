(async () => {
  let storage = await getDataSourceForDomain(window.location);
  let { tetrioPlusEnabled } = await storage.get('tetrioPlusEnabled');

  console.log("TETR.IO PLUS is installed");
  if (!tetrioPlusEnabled) {
    console.log("(but disabled)");
    return;
  }

  let port = browser.runtime.connect({ name: 'info-channel' });
  port.postMessage({ type: 'getInfoString' });
  port.postMessage({ type: 'showPageAction' });

  let jsLoadErr = document.getElementById("js_load_error");
  if (!jsLoadErr) {
    console.error("[TETR.IO PLUS] Can't find '#js_load_error'?");
  } else {
    let header = document.createElement('h2');
    header.innerText = "TETRIO PLUS is enabled";
    header.style.fontSize = '1.5rem';
    header.style.fontWeight = '500';
    header.style.color = 'red';
    jsLoadErr.insertBefore(header, document.getElementById('js_load_retry_button'));

    function paragraph(text) {
      let p = document.createElement('p');
      p.innerText = text;
      jsLoadErr.insertBefore(p, document.getElementById('js_load_retry_button'));
      return p;
    }

    paragraph(
      "Do not report errors to tetrio or osk while using TETRIO PLUS. " +
      "Try the following first:"
    );
    paragraph(
      "• Waiting for a bit. This screen can appear if the game is taking " +
      "longer to load than expected."
    );
    paragraph(
      "• Refreshing the page (ctrl-F5)"
    );
    paragraph("• Disabling features in the TETRIO PLUS menu");
    let update = paragraph("• Updating TETRIO PLUS. ")
    let faq = paragraph('');
    paragraph("• Removing TETRIO PLUS");

    port.onMessage.addListener(msg => {
      if (msg.type != 'getInfoStringResult') return;

      if (msg.value.indexOf('Tetrio Desktop') > 0) {
        let a = document.createElement('a');
        a.innerText = 'Get the latest release here';
        a.href = 'https://gitlab.com/UniQMG/tetrio-plus/-/releases';
        update.appendChild(a);

        faq.innerText = '• Review '
        let a2 = document.createElement('a');
        a2.innerText = 'this FAQ';
        a2.href = 'https://gitlab.com/UniQMG/tetrio-plus/-/wikis/desktop-faq';
        faq.appendChild(a2);
      } else {
        let span = document.createElement('span');
        span.innerText = `Check for updates from the firefox addons manager.`
        update.appendChild(span);
      }

      let p = paragraph(msg.value);
      p.style.color = '#666';
      p.style.fontSize = '1rem';
    });

  }


  let f8menu = document.getElementById('devbuildid');
  if (!f8menu) {
    console.log("[TETR.IO PLUS] Can't find '#devbuildid'?")
  } else {
    let div = document.createElement('div');
    f8menu.parentNode.insertBefore(div, f8menu.nextSibling);

    div.innerText = `TETRIO PLUS enabled`;
    div.style.fontFamily = 'PFW';

    port.onMessage.addListener(msg => {
      if (msg.type != 'getInfoStringResult') return;
      div.innerText = msg.value;
    });
  }
})().catch(console.error);
