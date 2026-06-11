import * as musicGraph from './music-graph-util.js';

function makeTemplate(name, callback) {
  let button = document.getElementById(name);
  button.addEventListener('click', async () => {
    try {
      let errors = await sanitizeAndLoadTPSE(
        await callback(),
        browser.storage.local,
        { skipFileDependencies: true }
      );
      if (/ERROR:/.test(errors))
        throw new Error('\n' + errors);
      alert("Template installed");
    } catch(ex) {
      alert("Template setup failed: " + ex);
      console.error(ex);
    }
  });
}

makeTemplate('videoBackgrounds', async () => {
  let { backgrounds } = await browser.storage.local.get('backgrounds');
  backgrounds = backgrounds?.filter(bg => bg.type == 'video');
  if (!backgrounds || backgrounds.length == 0)
    throw new Error("No video backgrounds installed");

  let nodes = [];
  let root = musicGraph.makeRootNode();
  nodes.push(root);
  root.triggers.push(musicGraph.makeTrigger({
    mode: 'random',
    event: 'node-end'
  }))

  for (let { id, filename } of backgrounds) {
    let node = musicGraph.makeNode({
      name: `background ${filename}`,
      background: id,
      x: 400,
      y: (nodes.length - 1) * 80
    });
    nodes.push(node);
    root.triggers.push(musicGraph.makeTrigger({
      mode: 'fork',
      event: 'random-target',
      target: node.id,
      anchor: { origin: { x: 200, y: 30 }, target: { x: 0, y: 30 } },
    }));
  }

  return {
    version: musicGraph.version,
    musicGraph: JSON.stringify(nodes),
    musicEnabled: true,
    musicGraphEnabled: true,
    bgEnabled: true,
    animatedBgEnabled: false,
    opaqueTransparentBackground: true,
    musicGraphBackground: true,
  }
});
