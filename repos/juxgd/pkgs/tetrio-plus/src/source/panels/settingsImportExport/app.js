import '../../shared/drop-handler.js';
import /* non es6 */ '../../shared/migrate.js';
import importer from '../../importers/import.js';
import readfiles from '../../shared/filehelper.js';
import { tpsecore, registerListener, registerTPSEImportEventHandler, setExternalTPSEHandler } from '../../lib/tpsecore.js';
window.tpsecore_debug = tpsecore;

registerListener(event => {
  if (event.kind != 'panic') return;
  alert("Something went catastrophically wrong with tpsecore. See console for details. Reload page before attempting to use tpsecore again.");
});

const BROWSER_STORAGE_EXTERN_TPSE = tpsecore.allocate_extern_tpse();
let storage_layer = {};
let storage_layer_deletes = {};
let import_running = false;
async function flushStorageLayer() {
  console.log("flushing changes to storage", {
    set: Object.keys(storage_layer),
    delete: Object.keys(storage_layer_deletes)
  });
  await browser.storage.local.set(storage_layer);
  for (let key of Object.keys(storage_layer_deletes))
    await browser.storage.local.remove(key);
  storage_layer = {};
  storage_layer_deletes = {};
}
function clearStorageLayer() {
  console.log("discarding storage layer changes");
  storage_layer = {};
  storage_layer_deletes = {};
}
setExternalTPSEHandler(
  async (tpse_id, key) => {
    if (tpse_id != BROWSER_STORAGE_EXTERN_TPSE) throw new Error("invalid extern tpse");
    let data = await browser.storage.local.get(key);
    console.log("storage value get", { tpse_id, key });
    if (storage_layer.hasOwnProperty(key)) {
      return storage_layer[key];
    }
    if (!data.hasOwnProperty(key)) {
      return null;
    }
    return data[key];
  },
  async (tpse_id, key, value) => {
    if (tpse_id != BROWSER_STORAGE_EXTERN_TPSE) throw new Error("invalid extern tpse");
    storage_layer[key] = value;
    delete storage_layer_deletes[key];
    console.log("storage value set", { tpse_id, key/*, value*/ });
  },
  async (tpse_id, key) => {
    if (tpse_id != BROWSER_STORAGE_EXTERN_TPSE) throw new Error("invalid extern tpse");
    delete storage_layer[key];
    storage_layer_deletes[key] = true;
    console.log("storage value delete", { tpse_id, key });
  }
);

(async () => {
  let match = /install=([^=]+)/.exec(new URL(window.location).search);
  if (match) {
    console.log(match);
    let url = decodeURIComponent(match[1]);

    for (let el of document.querySelectorAll("fieldset:not(#url-importer)"))
      el.style.display = 'none';

    let a = document.getElementById('url-anchor');
    a.href = url;
    a.innerText = url;

    document.getElementById('url-importer').style.display = 'block';
    document.getElementById('import-from-url').addEventListener('click', async () => {
      console.log('Installing ' + url);
      let status = document.createElement('div');
      status.innerText = 'working on import...';
      document.body.appendChild(status);

      try {
        let data = await (await fetch(url)).json();
        alert(await sanitizeAndLoadTPSE(data, browser.storage.local));
      } catch(ex) {
        alert("Failed to load content pack! See the console for more details");
        console.error("Failed to load content pack: ", ex);
        console.error(
          "If your content pack is more than a few hundred megabytes, the " +
          "parser may be running out of memory."
        );
      } finally {
        status.remove();
      }
    });
  }


  document.getElementById('import').addEventListener('change', async evt => {
    let status = document.createElement('div');
    status.innerText = 'working on import...';
    document.body.appendChild(status);

    try {
      let data = null;
      if (evt.target.files[0].name.endsWith('tpsez')) {
        status.innerText = 'working on import: load tpsez...';
        let zip = await JSZip.loadAsync(evt.target.files[0]);
        data = {};
        for (let [key, file] of Object.entries(zip.files)) {
          data[key] = JSON.parse(await file.async('string'))
        }
      } else {
        status.innerText = 'working on import: load tpse...';
        let reader = new FileReader();
        reader.readAsText(evt.target.files[0], "UTF-8");
        reader.onerror = () => alert("Failed to load content pack");
        await new Promise(res => reader.onload = res);
        data = JSON.parse(reader.result);
      }

      status.innerText = 'working on import: apply settings...';
      alert(await sanitizeAndLoadTPSE(data, browser.storage.local));
    } catch(ex) {
      alert("Failed to load content pack! See the console for more details");
      console.error("Failed to load content pack: ", ex);
      console.error(
        "If your content pack is more than a few hundred megabytes, the " +
        "parser may be running out of memory."
      );
    } finally {
      // reset the handler
      evt.target.type = '';
      evt.target.type = 'file';
      status.remove();
    }
  });


  async function exportKeys(entryCallback) {
    let presentKeys = new Set();
    async function exportKey(key) {
      let value = await browser.storage.local.get(key);
      if (!value[key]) return false;
      entryCallback(key, value[key]);
      presentKeys.add(key);
      return true;
    }

    if (!await exportKey('version'))
      throw new Error("Attempted to export, but missing key 'version'?");

    let elems = document.getElementsByClassName('export-toggle');
    for (let elem of elems) {
      if (elem.checked) {
        for (let key of elem.getAttribute('data-export').split(',')) {
          await exportKey(key);
        }
      }
    }

    if (presentKeys.has('animatedBackground')) {
      let { animatedBackground } = await browser.storage.local.get('animatedBackground');
      let key = 'background-' + animatedBackground.id;
      await exportKey(key);
    }

    if (presentKeys.has('backgrounds')) {
      let { backgrounds } = await browser.storage.local.get('backgrounds');
      let bgIds = backgrounds.map(({ id }) => 'background-' + id);
      for (let id of bgIds) await exportKey(id);
    }

    if (presentKeys.has('music')) {
      let { music } = await browser.storage.local.get('music');
      let musicIds = music.map(({ id }) => 'song-' + id);
      for (let id of musicIds) await exportKey(id);
    }
  }
  function offerDownload(filename, blob) {
      console.log("Offering download...");

      // https://stackoverflow.com/questions/3665115/18197341#18197341
      let a = document.createElement('a');
      let url = URL.createObjectURL(blob);
      a.setAttribute('href', url);
      a.setAttribute('download', filename);
      a.style.display = 'none';

      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);

      URL.revokeObjectURL(url);
  }
  document.getElementById('export').addEventListener('click', async evt => {
    let status = document.createElement('div');
    status.innerText = 'working on export...';
    document.body.appendChild(status);
    try {
      let config = {};
      await exportKeys((key, value) => config[key] = value);

      console.log("Encoding data...");
      let json = JSON.stringify(config, null, 2);
      let blob = new Blob([json], { type: 'application/json' });

      offerDownload('tetrio-plus-settings-export.tpse', blob);
      status.remove();
    } catch(ex) {
      alert(ex.toString());
      console.error(ex);
      status.remove();
    }
  });
  document.getElementById('export-zip').addEventListener('click', async evt => {
    let status = document.createElement('div');
    status.innerText = 'working on export...';
    document.body.appendChild(status);
    try {
      let zip = new JSZip();
      let config = {};
      await exportKeys((key, value) => {
        status.innerText = `working on export: key '${key}'...`;
        zip.file(key, JSON.stringify(value));
      });

      status.innerText = `working on export: generating zip (may take a while)...`;
      let zipstart = Date.now();
      let blob = await zip.generateAsync({
        type: "blob",
        // compression: "DEFLATE",
        // compressionOptions: { level: 1 }
      });
      console.log(`Zipping took ${Date.now() - zipstart}ms`);

      status.innerText = `working on export: offering download...`;
      offerDownload('tetrio-plus-settings-export.tpsez', blob);
      status.remove();
    } catch(ex) {
      alert(ex.toString());
      console.error(ex);
      status.remove();
    }
  });


  document.getElementById('clearData').addEventListener('click', async () => {
    if (confirm('Are you sure you want to clear all your TETR.IO PLUS data?')) {
      await browser.storage.local.clear();
      await migrate(browser.storage.local);
      alert('Data cleared');
    }
  });


  document.getElementById('import-anything').addEventListener('change', async (evt) => {
    let useExperimental = document.getElementById('use-experimental').checked;
    let status = document.getElementById('import-anything-status');
    status.innerText = "Working...";
    await new Promise(res => setTimeout(res, 50));
    let start = Date.now();
    
    try {
      if (useExperimental) {
        await tpsecoreImport(evt.target);
        status.innerText = "";
      } else {
        let logs = [];
        try {
          await classicImport(evt.target, logs);
          alert(`Import successful! (took ${Date.now() - start}ms)\n\nImport logs:\n${logs.join('\n')}`);
          status.innerText = "Import successful";
        } catch(ex) {
          alert(`Import failed: ${ex} (took ${Date.now() - start}ms)\n\nImport logs:\n${logs.join('\n')}`);
          status.innerText = "Import failed";
          console.error(ex);
        }
      }
    } finally {
      // reset the handler
      evt.target.type = '';
      evt.target.type = 'file';
    }

  });

  async function classicImport(input, logs) {
    await importer.automatic(
      await readfiles(input),
      browser.storage.local,
      {
        log(...msg) {
          console.log(msg.join(' '));
          logs.push(msg.join(' '));
        }
      }
    );
  }

  async function tpsecoreImport(input) {
    if (import_running) throw new Error("import already running");
    import_running = true;
    let tpse = BROWSER_STORAGE_EXTERN_TPSE;
    
    function assert_eq(a, b, label) {
      if (a != b) throw new Error(`assertion at ${label} failed: ${a} != ${b}`);
    }
    
    console.log("Loading files...", Date.now());
    
    let import_gui_wrapper = null;
    try {
      for (let file of input.files) {
        let reader = new FileReader();
        reader.readAsArrayBuffer(file, "UTF-8");
        let content = await new Promise((res, rej) => {
          reader.onerror = err => rej(new Error("Reading file failed", { cause: err }));
          reader.onload = _evt => res(new Uint8Array(reader.result));
        });
        console.log(content);
        
        let encoded = new TextEncoder().encode(file.name);
        let fptr = tpsecore.allocate_buffer(encoded.length);
        let fbuffer = new Uint8Array(tpsecore.memory.buffer, fptr, encoded.length);
        fbuffer.set(encoded);
        
        let cptr = tpsecore.allocate_buffer(content.length);
        let cbuffer = new Uint8Array(tpsecore.memory.buffer, cptr, content.length);
        cbuffer.set(content);
        
        assert_eq(0, tpsecore.stage_file(tpse, fptr, cptr), 'stage file');
      }
      
      console.log("Running import...", Date.now());
      
      import_gui_wrapper = document.createElement('div');
      document.body.appendChild(import_gui_wrapper);
      import_gui_wrapper.innerHTML = `
        <style>
          @scope {
            .import-gui-background {
              position: fixed;
              left: 0px;
              top: 0px;
              width: 100vw;
              height: 100vh;
              background: #77777777;
            }
            .import-gui {
              position: fixed;
              
              max-width: calc(100vw - 40px);
              max-height: calc(100vh - 40px); 
              top: 50%;
              left: 50%;
              transform: translate(-50%, -50%);
              
              padding: 10px;
              background-color: white;
              border: 3px solid black;
              box-sizing: border-box;
              border-radius: 5px;
              
              overflow-y: auto;
            }
            
            .decision-tree-placeholder {
              font-style: italic;
            }
            .decision-tree-root {
            }
            .decision-tree-branch {
              padding-left: 20px;
              margin-top: 5px;
              margin-bottom: 5px;
            }
            
            .default-option {
              font-style: italic;
            }
            
            .import-log {
              height: 200px;
              overflow-y: scroll;
              background-color: #DDD;
              font-family: monospace;
              padding: 4px;
            }
            
            .section-header {
              margin-top: 10px;
              margin-bottom: 4px;
              border-bottom: 2px dotted black;
              font-weight: bold;
            }
            
            .tpsecore-status:not(:empty)::before {
              content: ': ';
            }
            
            .log.debug, .log.trace {
              display: none;
            }
            
            .log-level {
              background-color: var(--log-color);
              margin-right: 4px;
              width: 8ch;
              display: inline-block;
              text-align: center;
            }
            .error .log-level { --log-color: red; }
            .warn .log-level { --log-color: yellow; }
            .info .log-level { --log-color: lime; }
            .status .log-level { --log-color: cyan; }
            .debug .log-level { --log-color: blue; }
            .trace .log-level { --log-color: dimgray; }
            
            .status.complete { background-color: lime; }
            .status.failed { background-color: red; }
          
            .smalltext {
              font-style: italic;
              font-size: 10pt;
              color: #333;
            }
            @media (width > 450px) {
              .smalltext {
                white-space: nowrap; /* provides a decent minimum width for the component and just looks better */
              }
            }
          }
        </style>
        
        <div class="import-gui-background"></div>
        
        <div class="import-gui">
          <div class="status">Import running<span class="tpsecore-status"></span></div>
          
          <div class="section-header">Configure content pack</div>
          <div class="decision-tree-placeholder">
            No options yet
          </div>
          
          <div class="section-header">Import log</div>
          <div class="import-log"></div>
          <div class="smalltext">For extended log content, see devtools or open in tpsecore studio</div>
          
          <div>
            <button class="close-button" disabled="true" style="margin-top: 10px;">close</button>
          </div>
        </div>
      `;
      
      let queue_import = new Promise(res => {
        registerTPSEImportEventHandler(
          tpse, 
          res,
          async decision => {
            let decisionRoot = document.createElement('div');
            import_gui_wrapper.querySelector('.decision-tree-placeholder').replaceWith(decisionRoot);
            decisionRoot.classList.add('decision-tree-root');
            decisionRoot.innerHTML = `
              <div class="options"></div>
              <button disabled="true">confirm</button>
            `;
            let queue = decision.reverse().map(decision => {
              return { parent: decisionRoot.querySelector('.options'), decision };
            });
            let decisionsRequired = [];
            let decisionsMade = {};
            let decisionsAvailable = false;
            function updateConfirmEnabled() {
              let ready = decisionsRequired.every(id => decisionsMade.hasOwnProperty(id));
              let button = decisionRoot.querySelector('button');
              button.disabled = !ready;
            }
            while (queue.length > 0) {
              let entry = queue.pop();
              
              if (entry.decision.options.length > 1) {
                decisionsAvailable = true;
              }
              
              let container = document.createElement('ul');
              entry.parent.appendChild(container);
              container.classList.add('decision-tree-branch');
              container.append(entry.decision.description);
              
              if (entry.decision.required) {
                decisionsRequired.push(entry.decision.id);
              } else {
                let li = document.createElement('li');
                container.appendChild(li);
                
                let input = document.createElement('input');
                li.appendChild(input);
                input.type = 'radio';
                input.id = Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
                input.name = `decision${entry.decision.id}`;
                input.addEventListener('change', () => {
                  delete decisionsMade[entry.decision.id];
                });
                input.checked = true;
                
                let label = document.createElement('label');
                li.appendChild(label);
                label.htmlFor = input.id;
                label.textContent = 'None';
                label.classList.add('default-option');
              }
              
              for (let i = 0; i < entry.decision.options.length; i++) {
                let option = entry.decision.options[i];
                
                let li = document.createElement('li');
                container.appendChild(li);
                
                let input = document.createElement('input');
                li.appendChild(input);
                input.type = 'radio';
                input.id = Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
                input.name = `decision${entry.decision.id}`;
                input.addEventListener('change', () => {
                  decisionsMade[entry.decision.id] = i;
                  updateConfirmEnabled();
                });
                if (entry.decision.options.length == 1) {
                  decisionsMade[entry.decision.id] = 0;
                  input.checked = true;
                }
                
                let label = document.createElement('label');
                li.appendChild(label);
                label.htmlFor = input.id;
                label.textContent = option.description;
                
                for (let subtree of option.subtrees) {
                  queue.push({ parent: container, decision: subtree });
                }
              }
            }
            updateConfirmEnabled();
            await new Promise(res => {
              decisionRoot.querySelector('button').addEventListener('click', res);
              if (!decisionsAvailable) res();
            });
            console.log("import option result", {decisionsRequired, decisionsMade, decisionsAvailable});
            document.getElementById('import-anything-status').innerText = `Working... (Decision made)`;
            import_gui_wrapper.querySelector('.tpsecore-status').innerText = 'Decision made';
            decisionRoot.querySelectorAll('input').forEach(el => el.disabled = true);
            decisionRoot.querySelector('button').disabled = true;
            return decisionsMade;
          },
          log => {
            console.log("tpsecore log>", log);
            if (log.level == 'trace') return;
            
            let import_log = import_gui_wrapper.querySelector('.import-log');
            
            let log_element = document.createElement('div');
            log_element.classList.add('log', log.level);
            import_log.appendChild(log_element);
            
            let level = document.createElement('span');
            level.classList.add('log-level');
            level.innerText = log.level;
            log_element.appendChild(level);
            
            log_element.append(log.message);
            
            import_log.scrollTop = import_log.scrollHeight;
            
            if (log.level == 'status') {
              document.getElementById('import-anything-status').innerText = `Working... (${log.message})`;
              import_gui_wrapper.querySelector('.tpsecore-status').innerText = log.message;
            }
          }
        );
      });
      assert_eq(0, tpsecore.queue_import(tpse), 'queue import');
      let queue_import_result = await queue_import;
      
      switch (queue_import_result) {
        case 0: break;
        case 1: throw new Error("general error (see logs)");
        case 2: throw new Error("internal error (invalid tpse handle)");
        default: throw new Error("unknown error " + queue_import_result);
      }
      await flushStorageLayer();
      let status = import_gui_wrapper.querySelector('.status');
      status.innerText = 'Import complete';
      status.classList.add('complete');
    } catch(ex) {
      let status = import_gui_wrapper.querySelector('.status');
      status.innerText = 'Import failed: ' + ex;
      status.classList.add('failed');
      clearStorageLayer();
    } finally {
      assert_eq(0, tpsecore.clear_staged_files(tpse, true), "clear staged files");
      import_running = false;
      
      await new Promise(res => {
        let button = import_gui_wrapper.querySelector('.close-button');
        button.addEventListener('click', res);
        button.disabled = false;
      });
      import_gui_wrapper.remove();
    }
  }


  const sampleRate = 44100;
  const channels = 2;
  const quality = 1.0;
  document.getElementById('decompileSfx').addEventListener('click', async () => {
    let { customSoundAtlas, customSounds } = await browser.storage.local.get([
      'customSoundAtlas', 'customSounds'
    ]);
    if (!customSoundAtlas || !customSounds) {
      alert('No custom sfx configured.');
      return;
    }
    let status = document.createElement('div');
    status.innerText = 'working on export...';
    document.body.appendChild(status);


    const soundBuffer = await new window.OfflineAudioContext(
      channels,
      sampleRate,
      sampleRate
    ).decodeAudioData(await (await fetch(customSounds)).arrayBuffer());

    let zip = new JSZip();
    for (let [name, [ offset, duration ]] of Object.entries(customSoundAtlas)) {
      status.innerText = `working on export: ${name}.ogg...`;
      // Convert milliseconds to seconds
      offset /= 1000; duration /= 1000;

      const ctx = new window.OfflineAudioContext(
        channels,
        sampleRate*duration,
        sampleRate
      );

      let source = ctx.createBufferSource();
      source.buffer = soundBuffer;
      source.connect(ctx.destination);
      source.start(0, offset, duration);
      let slicedBuffer = await ctx.startRendering();

      let encoder = new window.OggVorbisEncoder(sampleRate, channels, quality);
      encoder.encode([
        slicedBuffer.getChannelData(0),
        slicedBuffer.getChannelData(1)
      ]);
      let blob = encoder.finish();
      zip.file(name + '.ogg', blob);
    }

    status.innerText = `working on export: generating zipfile...`;
    let blob = await zip.generateAsync({ type: 'blob' });

    let a = document.createElement('a');
    a.setAttribute('href', URL.createObjectURL(blob));
    a.setAttribute('download', 'tetrio-plus-sfx-export.zip');
    a.style.display = 'none';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    status.remove();
  });


  let oaiw = document.getElementById('open-auto-import-wiki');
  oaiw.href = 'https://gitlab.com/UniQMG/tetrio-plus/-/wikis/automatic-imports';
  oaiw.addEventListener('click', evt => {
    evt.preventDefault();
    if (window.openInBrowser) { // electron
      window.openInBrowser('https://gitlab.com/UniQMG/tetrio-plus/-/wikis/automatic-imports');
    } else {
      window.open('https://gitlab.com/UniQMG/tetrio-plus/-/wikis/automatic-imports');
    }
  });
})();
