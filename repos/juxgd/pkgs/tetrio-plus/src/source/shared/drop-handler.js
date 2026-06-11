import filehelper from './filehelper.js';
import importer from '../importers/import.js';

document.body.addEventListener('dragover', evt => {
  evt.preventDefault();
});
document.body.addEventListener('drop', async evt => {
  evt.preventDefault();

  let files = [...evt.dataTransfer.items]
    .filter(item => item.kind == 'file')
    .map(item => item.getAsFile())

  if (files.length == 0)
    return;

  let pre = document.createElement('pre');
  pre.classList.add('drop-handler-log');
  pre.style.position = 'fixed';
  pre.style.top = '0px';
  pre.style.left = '0px';
  pre.style.width = '100vw';
  pre.style.height = '100vh';
  pre.style.background = '#000000DD';
  pre.style.color = 'white';
  pre.style.margin = '0px';
  pre.style.padding = '8px';
  pre.style.fontSize = '12pt';
  pre.style.overflow = 'auto';
  pre.style.whiteSpace = 'break-spaces';
  document.body.append(pre);

  function doclog(msg) {
    let div = document.createElement('div');
    div.innerText = msg;
    pre.appendChild(div);
  }

  doclog('Importing file...');

  console.log("dropped files", evt, files);
  let log = [];

  try {
    await importer.automatic(
      await filehelper({ files }),
      browser.storage.local,
      { log(...msg) {
        doclog(msg.join(' '));
        log.push(msg.join(' '));
      } }
    );

    alert("Automatic import successful\n\nLog:\n" + log.join("\n"));
  } catch(ex) {
    console.error(ex);
    alert("Automatic import failed: " + ex + "\n\nLog:\n" + log.join("\n"));
  } finally {
    for (let line of log)
      console.log(line);
  }

  window.location.reload();
});
