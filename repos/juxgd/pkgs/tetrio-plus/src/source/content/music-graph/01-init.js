const modules = [];
function musicGraph(module) {
  modules.push(module);
}

(async function initializeMusicGraph(createRoot=true) {
  if (window.location.pathname != '/') return;
  let storage = await getDataSourceForDomain(window.location);
  let { tetrioPlusEnabled } = await storage.get('tetrioPlusEnabled');
  if (!tetrioPlusEnabled) return;
  let {
    music,
    backgrounds,
    musicGraph,
    musicEnabled,
    musicGraphEnabled,
    musicGraphBackground,
    musicGraphNodeLimit,
    musicGraphReportedEventRateLimit,
    musicGraphHardEventRateLimit
  } = await storage.get([
    'music',
    'backgrounds',
    'musicGraph',
    'musicEnabled',
    'musicGraphEnabled',
    'musicGraphBackground',
    'musicGraphNodeLimit',
    'musicGraphReportedEventRateLimit',
    'musicGraphHardEventRateLimit'
  ]);
  if (!musicEnabled || !musicGraphEnabled)
    return;
  musicGraph = musicGraph ?? [];
  musicGraphNodeLimit = musicGraphNodeLimit ?? 100;
  musicGraphReportedEventRateLimit = musicGraphReportedEventRateLimit ?? 250;
  musicGraphHardEventRateLimit = musicGraphHardEventRateLimit ?? 10000;

  const musicRoot = '/res/bgm/akai-tsuchi-wo-funde.mp3?song=';
  const audioContext = new AudioContext();

  // wait to initialize audio context, which won't initialize at this point because it requires a user gesture to start
  while (audioContext.state == 'suspended') {
    console.log('[TETR.IO PLUS] Attempting to unsuspend audio context');
    // don't await, it hangs
    audioContext.resume().catch(err => console.error('[TETR.IO PLUS] ' + err));
    await new Promise(res => setTimeout(res, 1000));
  }
  const audioBuffers = {};

  const graph = {};
  for (let src of musicGraph) {
    graph[src.id] = src;
    if (!src.audio) continue;
    if (audioBuffers[src.audio]) continue;

    let key = 'song-' + src.audio;
    let base64 = (await storage.get(key))[key];
    let rawBuffer = await fetch(base64).then(res => res.arrayBuffer());
    let decoded = await audioContext.decodeAudioData(rawBuffer);
    audioBuffers[src.audio] = decoded;
  }

  let globalVolume = 0;
  let lastUpdate = 0;
  function getGlobalVolume() {
    if (Date.now() - lastUpdate > 1000) {
      globalVolume = JSON.parse(localStorage.userConfig).volume.music;
      lastUpdate = Date.now();
    }
    return globalVolume;
  }

  const musicGraphData = {
    initializeMusicGraph,
    globalVariables: {},
    nodes: [],
    cleanup: [],
    audioContext,
    graph,
    imageCache: {},
    audioBuffers,
    getGlobalVolume,
    musicGraphNodeLimit,
    musicGraphReportedEventRateLimit,
    musicGraphHardEventRateLimit,
    backgroundsEnabled: musicGraphBackground
  };

  musicGraphData.cleanup.push(() => {
    audioContext.close();
  });

  // cache images so they can appear instantly
  for (let el of Object.values(graph)) {
    if (!el.background) continue;

    let bg = backgrounds.filter(e => e.id == el.background)[0];
    let ext = bg?.filename?.split('.')?.slice(-1)?.[0] || 'png';

    if (bg.type == 'video') {
      let video = document.createElement('video');
      let url = window.location.origin + '/res/bg/1.jpg?bgId=' + el.background;
      let mime = ext == 'mp4' ? 'video/mp4' : 'video/webm';
      let wrongBlob = await (await fetch(url)).blob();
      let rightBlob = wrongBlob.slice(0, wrongBlob.size, mime);
      video.src = URL.createObjectURL(rightBlob);
      video.preload = 'auto';
      video.muted = true;
      video.loop = true;
      video.style.width = '100vw';
      video.style.height = '100vh';
      video.style.position = 'fixed';
      video.style.objectFit = 'cover';
      video.style['z-index'] = '-1';
      musicGraphData.imageCache[el.id] = { base: video, ready: [video] };
    } else {
      let img = new Image();
      img.src = '/res/bg/1.jpg?bgId=' + el.background;
      img.style.width = '100vw';
      img.style.height = '100vh';
      img.style.position = 'fixed';
      img.style.objectFit = 'cover';
      img.style['z-index'] = '-1';
      musicGraphData.imageCache[el.id] = { base: img, ready: [img] };
    }
  }

  let preloadContainer = document.createElement('div');
  preloadContainer.classList.add('tetrio-plus-preload-container');
  for (let { base: node } of Object.values(musicGraphData.imageCache)) {
    node.style.opacity = 0;
    preloadContainer.appendChild(node); // force preload
  }
  document.body.appendChild(preloadContainer);

  for (let module of modules)
    module(musicGraphData);

  if (createRoot) {
    for (let graphObject of Object.values(graph)) {
      if (graphObject.type != 'root') continue;
      let node = new musicGraphData.Node();
      musicGraphData.nodes.push(node);
      node.setSource(graphObject);
    }
  }

  console.log("[TETR.IO PLUS] Music graph ready");
  return musicGraphData;
})().catch(ex => {
  console.error("[TETR.IO PLUS] Music graph error:", ex);
});
