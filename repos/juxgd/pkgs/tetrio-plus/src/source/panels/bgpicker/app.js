import { loadIndividual, randomId } from '../../importers/background.js';
import filehelper from '../../shared/filehelper.js';

async function importFile(elementId, handler) {
  let el = document.getElementById(elementId);
  el.addEventListener('change', async evt => {
    let files = await filehelper(el);
    console.log("Files", files);

    let status = document.createElement('em');
    status.innerText = 'processing...';
    document.body.appendChild(status);
    window.scrollTo(0, document.body.scrollHeight);

    for (let file of await filehelper(el)) {
      await handler(file);
    }

    el.type = '';
    el.type = 'file';
    status.remove();
    alert("Done!");
  }, false);
}

importFile('regular', async file => {
  await loadIndividual(file, 'image', browser.storage.local);
});
importFile('video', async file => {
  await loadIndividual(file, 'video', browser.storage.local);
});
importFile('animated', async file => {
  let id = randomId();
  let { animatedBackground } = await browser.storage.local.get('animatedBackground');
  if (animatedBackground) {
    await browser.storage.local.remove(`background-${animatedBackground.id}`);
  }
  await browser.storage.local.set({
    animatedBackground: { id, filename: file.name },
    ['background-' + id]: file.data
  });
});
