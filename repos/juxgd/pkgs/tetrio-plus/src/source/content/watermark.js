(async () => {
  if (window.location.pathname != "/") return;
  let enabled = await browser.storage.local.get(['tetrioPlusEnabled', 'watermarkEnabled']);
  if (!enabled.tetrioPlusEnabled || !enabled.watermarkEnabled) return;
  let style = `
    #tetrio_plus_indicator {
      display: grid;
      grid-template: "left right" auto / auto;
      
      position: fixed;
      top: 0px;
      left: 0px;
      z-index: 01189998819991197253;
      
      opacity: 1;
      
      pointer-events: none;
      font-family: monospace;
      font-weight: bold;
      color: #FFF;
      --bg: #1118;
      --bg-fill: #111A;
    }

    #tetrio_plus_indicator > .tpi_body {
      display: flex;
      border: 8px solid var(--bg-fill);
    }
    
    /* need a wrapper here to prevent the background going under the border and making it more opaque than desired */
    #tetrio_plus_indicator > .tpi_body > .tpi_body_inner {
      display: grid;
      grid-template: "left right" auto / auto auto;
      
      background: var(--bg);
      padding: 6px;
    }
    
    #tetrio_plus_indicator > .tpi_body > .tpi_body_inner > .tpi_logo_wrapper {
      display: inline-block;
      
      height: 100%;
      width: 60px; /* changed by js later */
      margin-right: 8px;
      
      background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAABmJLR0QA/wAAAAAzJ3zzAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAB3RJTUUH6QIJBDYhOCvV9wAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAABjSURBVAjXY7zvt+o/AxQobgpjhLEZGRgYGO77rfoPExSdOPc/AwMDAxMDAwPDw08MDHXxj//rB676f8ptIwNcAgY2tC1hYGBgYDjlthFVIqAqBmKX5iZGFmSJi+vDGBXXQ9gAHhQbMOg54HMAAAAASUVORK5CYII=");
      background-size: contain;
      background-repeat: no-repeat;
      image-rendering: pixelated;
    }
    .tpi_logo_wrapper_glow {
      background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAABmJLR0QA/wAAAAAzJ3zzAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAB3RJTUUH6QIJBzQWsOasIwAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAAbSURBVAjXY2CgGNy/7vefgYGBgRGbIF4dOAEAC8UJC9qopmQAAAAASUVORK5CYII=");
      background-size: contain;
      background-repeat: no-repeat;
      image-rendering: pixelated;
      width: 100%;
      height: 100%;
      filter: brightness(150%) saturate(150%) blur(3px);
    }
    
    #tetrio_plus_indicator > .tpi_body > .tpi_body_inner > .tpi_content {
      display: inline-block;
    }

    #tetrio_plus_indicator > .tpi_edge {
      height: 100%;
      background-color: var(--bg-fill);
      clip-path: polygon(0% 0%, 100% 0%, 0% 100%);
    }
    
    #tetrio_plus_indicator .tpi_icons {
      margin-left: 6px;
    }
    #tetrio_plus_indicator .tpi_icons > .tpi_icon {
      height: 16px;
      vertical-align: middle;
      margin-left: 3px;
      /*width: 1em;
      height: 1em;
      
      transform: translateY(-1px) scale(1.5);
      margin-left: 6px;
      image-rendering: pixelated;*/
    }
  `;
  
  let html = `
    <style>${style}</style>
    <div class="tpi_body">
      <div class="tpi_body_inner">
        <div class="tpi_logo_wrapper">
          <div class="tpi_logo_wrapper_glow">
          </div>
        </div>
        <div class="tpi_content">
          <div>TETR.IO PLUS - https://tetrio.plus</div>
          <div>This game is using a third-party mod.</div>
          <div>Modified:<span class="tpi_icons"></span></div>
        </div>
      </div>
    </div>
    <!-- hack for 1:1 aspect ratio, adapted from: https://stackoverflow.com/a/46045686 -->
    <!-- for some insane reason, putting this in a container won't stretch the container to fit. even with width: max-width. I hate css -->
    <!-- instead, just use it directly. -->
    <img class="tpi_edge" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7">
  `;

  document.querySelector('#tetrio_plus_indicator')?.remove();
  let container = document.createElement('div');
  container.id = 'tetrio_plus_indicator';
  container.innerHTML = html;
  document.body.appendChild(container);
  
  function updateCornerWidth() {
    let w = container.querySelector('.tpi_logo_wrapper');
    let { height } = w.getBoundingClientRect();
    w.style.width = height + 'px';
  }
  updateCornerWidth();
  
  let show_icons = [
    {
      keys: ['skin', 'ghost'],
      op: x => x.skin || x.ghost,
      sprite: [0, 0, 16, 16],
      canvas_resolution: [96, 96],
      special: (canvas) => {
        // draw the actual skin over the skin icon, which provides both a neat effect and good transparent fallback behavior
        let skin = new Image();
        skin.src = 'https://tetr.io/res/skins/minos/connected.2x.png';
        new Promise(res => skin.onload = res).then(() => {
          canvas.getContext('2d').drawImage(skin, 768, 288, 96, 96, 0, 0, canvas.width, canvas.height);
        });
      }
    },
    { keys: ['musicEnabled', 'music'], sprite: [16, 0, 16, 16] },
    { keys: ['sfxEnabled', 'customSoundAtlas'], sprite: [32, 0, 16, 16] },
    { keys: ['board', 'queue', 'grid'], sprite: [48, 0, 16, 16] },
    { keys: ['advancedSkinLoading'], sprite: [0, 16, 16, 16] },
    { keys: ['musicEnabled', 'musicGraphEnabled', 'musicGraph' ], sprite: [16, 16, 16, 16] },
    { keys: ['bgEnabled', 'backgrounds'], sprite: [32, 16, 16, 16] },
    {
      keys: ['particle_beam', 'particle_beams_beam', 'particle_bigbox', 'particle_box', 'particle_chip', 'particle_chirp', 'particle_dust', 'particle_fbox', 'particle_fire', 'particle_particle', 'particle_smoke', 'particle_star', 'particle_flake', 'rank_d', 'rank_dplus', 'rank_cminus', 'rank_c', 'rank_cplus', 'rank_bminus', 'rank_b', 'rank_bplus', 'rank_aminus', 'rank_a', 'rank_aplus', 'rank_sminus', 'rank_s', 'rank_splus', 'rank_ss', 'rank_u', 'rank_x', 'rank_z'],
      sprite: [48, 16, 16, 16]
    },
    { keys: ['enableTouchControls', 'touchControlConfig'], sprite: [64, 16, 16, 16] },
    {
      keys: ['bypassBootstrapper', 'enableAllSongTweaker', 'enableCustomCss', 'transparentBgEnabled', 'enableEmoteTab', 'enableOSD'],
      op: x => Object.values(x).some(x=>x),
      sprite: [64, 0, 16, 16]
    },
  ];
  
  let icons = container.querySelector('.tpi_icons');
  
  let feature_icons_atlas = new Image();
  feature_icons_atlas.src = browser.extension.getURL('icons/feature-icons.png');
  await new Promise(res => feature_icons_atlas.onload = res);
  for (let icon of show_icons) {
    let values = await browser.storage.local.get(icon.keys);
    function defaultTest() {
      for (let key of icon.keys)
        if (!values[key]) return false;
      return true;
    }
    let result = (icon.op || defaultTest)(values)
    if (!result) continue;
    
    let canvas = document.createElement('canvas');
    canvas.classList.add('tpi_icon');
    let [w, h] = icon.canvas_resolution || [16, 16];
    canvas.width = w;
    canvas.height = h;
    canvas.getContext('2d').drawImage(feature_icons_atlas, ...icon.sprite, 0, 0, canvas.width, canvas.height);
    icons.appendChild(canvas);
    icon.special?.(canvas);
  }
  
  updateCornerWidth();
})();