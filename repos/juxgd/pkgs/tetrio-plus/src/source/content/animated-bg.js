(async () => {
  let storage = await getDataSourceForDomain(window.location);
  let res = await storage.get([
    'bgEnabled',
    'animatedBgEnabled',
    'transparentBgEnabled',
    'tetrioPlusEnabled',
    'musicGraphBackground'
  ]);
  if (!res.tetrioPlusEnabled) return;

  if (res.transparentBgEnabled) {
    document.documentElement.style.background = 'transparent';
    document.body.style.background = 'transparent';

    let draggable = document.createElement('div');
    draggable.classList.add('draggable-header-overlay');
    document.body.appendChild(draggable);
  }

  if (!res.musicGraphBackground && res.bgEnabled && res.animatedBgEnabled) {
    let canvas = document.getElementById('pixi');
    canvas.style.backgroundImage = 'url(/res/bg/1.jpg?bgId=animated)';
    canvas.style.backgroundPosition = 'center';
    canvas.style.backgroundSize = 'cover';
  }
})().catch(console.error);
