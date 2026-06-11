import { KEYS } from '../../importers/generic-texture.js';
import importer from '../../importers/import.js';
const html = arg => arg.join('');

let app = new Vue({
  template: html`
    <div>
      <h1>TETR.IO PLUS quick fixes</h1>
      <div v-if="status">{{ status }}</div>

      <fieldset>
        <legend>Other skins</legend>
        <div v-if="!textures">
          Checking...
        </div>
        <ul v-else>
          <li v-for="texture of textures.filter(tex => !['ok', 'unset'].includes(tex.status))">
            {{ texture.key.toLowerCase() }}:
            <span v-if="texture.status == 'size-mismatch'">
              incorrect size <button @click="cropTexture(texture)">Accept attempted fix</button>
            </span>
            <span v-else-if="texture.status == 'vanilla-failed'">
              base game texture failed to load. For event-only skins, this may be normal.
            </span>
            <span v-else-if="texture.status == 'current-failed'">
              the texture failed to load and may be corrupt.
              <button @click="removeTexture(texture)">Remove</button>
            </span>
            <span v-else-if="texture.status == 'fixed'">
              Fix applied
            </span>
            <span v-else>
              {{ texture.status }}
            </span>
            <div class="image-containers">
              <div class="image-container" v-if="texture.vanillaImage">
                <div class="image-box">
                  <img :src="texture.vanillaImage.src" width="100"></img>
                </div>
                <span class="label">Vanilla ({{texture.vanillaImage.naturalWidth}}x{{texture.vanillaImage.naturalHeight}})</span>
              </div>
              <div class="image-container" v-if="texture.currentImage">
                <div class="image-box">
                  <img :src="texture.currentImage.src" width="100"></img>
                </div>
                <span class="label">Current ({{texture.currentImage.naturalWidth}}x{{texture.currentImage.naturalHeight}})</span>
              </div>
              <div class="image-container" v-if="texture.croppedImage">
                <div class="image-box">
                  <img :src="texture.croppedImage.src" width="100"></img>
                </div>
                <span class="label">Attempted fix ({{texture.croppedImage.naturalWidth}}x{{texture.croppedImage.naturalHeight}})</span>
              </div>
            </div>
          </li>
          <li>{{ textures.filter(tex => tex.status == 'ok').length }} correctly sized textures<br></li>
          <li>{{ textures.filter(tex => tex.status == 'unset').length }} unset textures</li>
        </ul>
      </fieldset>

      <fieldset>
        <legend>Music</legend>
        See <a href="https://gitlab.com/UniQMG/tetrio-plus/-/issues/50">this issue</a> for details on what this fix does.
        If this fix detects issues, consider reporting them in the issue thread or on Discord.<br><br>
        <div v-if="!music">Checking...</div>
        <div v-else-if="music.status == 'no-music'">No custom music</div>
        <div v-else-if="music.status == 'ok'">No issues detected</div>
        <div v-else-if="music.status == 'not-ok'">
          Issues detected. <button @click="fixMusic">Discard invalid data</button>
          <ul>
            <li v-for="issue of music.issues">
              {{ issue }}
            </li>
          </ul>
        </div>
        <div v-else-if="music.status == 'fixed'">Fix applied</div>
        <div v-else>{{ music.status }}</div>
      </fieldset>

      <fieldset>
      	<legend>Sound effects</legend>
      	<div v-if="!sfx">Checking...</div>
      	<div v-else-if="sfx.status == 'no-sfx'">No sound effects configured</div>
      	<div v-else-if="sfx.status == 'ok'">Sound effects ok</div>
      	<div v-else-if="sfx.status == 'not-ok'">
          Missing sound effects: <code>{{ sfx.missing.join(', ') }}</code>.<br>
          Populate these with base game sound effects in the <a href="../sfxcomposer/index.html">sound effects editor</a> by
          clicking <code>Decompile and load current soundpack</code> and then <code>Re-encode and save changes</code>.
      	</div>
      	<div v-else>{{ sfx.status }}</div>
      </fieldset>
    </div>
  `,
  data: () => ({
    status: 'Starting check',
    textures: null,
    music: null,
    sfx: null
  }),
  async mounted() {
    this.textures = await checkTextures(status => this.status = 'Checking textures: ' + status);
    this.music = await checkMusic(status => this.status = 'Checking music: ' + status);
    this.sfx = await checkSfx(status => this.status = 'Checking sfx: ' + status);
    this.status = 'Checks finished.';
  },
  methods: {
    async removeTexture(texture) {
      if (!texture.storagekey) throw '???';
      await browser.storage.local.remove(texture.storagekey);
      texture.status = 'fixed';
    },
    async cropTexture(texture) {
      if (!texture.storagekey || !texture.croppedImage?.src) throw '???';
      await browser.storage.local.set({ [texture.storagekey]: texture.croppedImage.src });
      texture.status = 'fixed';
    },
    async fixMusic() {
      if (!this.music.fixed) throw '???';
      await browser.storage.local.set({ musicBackup: (await browser.storage.local.get('music')).music });
      await browser.storage.local.set({ music: JSON.parse(JSON.stringify(this.music.fixed)) });
      this.music.status = 'fixed';
    }
  }
});
app.$mount('#app');
window.app = app;

async function checkTextures(status) {
  let textures = [];

  for (let [key, { url, storagekey, filekey }] of Object.entries(KEYS)) {
    status('custom texture: ' + storagekey);
    let current = (await browser.storage.local.get(storagekey))[storagekey];
    if (!current) {
      textures.push({ key, storagekey, url, status: 'unset' });
      continue;
    }

    let currentImage = new Image();
    let currentImageLoaded = await new Promise(res => {
      currentImage.onload = () => res(true);
      currentImage.onerror = () => res(false);
      currentImage.src = current;
    });
    if (!currentImageLoaded) {
      textures.push({ key, storagekey, url, status: 'current-failed' });
      continue;
    }


    let vanillaImage = new Image();
    vanillaImage.src = url + '?bypass-tetrio-plus';
    let vanillaImageLoaded = await new Promise(res => {
      vanillaImage.onload = () => res(true);
      vanillaImage.onerror = () => res(false);
    });
    if (!vanillaImageLoaded) {
      textures.push({ key, storagekey, url, currentImage, status: 'vanilla-failed' });
      continue;
    }

    let wOk = currentImage.naturalWidth == vanillaImage.naturalWidth;
    let hOk = currentImage.naturalHeight == vanillaImage.naturalHeight;
    if (!wOk || !hOk) {
      let canvas = document.createElement('canvas');
      canvas.width = vanillaImage.naturalWidth;
      canvas.height = vanillaImage.naturalHeight;
      let ctx = canvas.getContext('2d');

      let src = browser.electron
        ? vanillaImage.src.replace('https://tetr.io/', 'tetrio-plus://tetrio-plus/')
        : vanillaImage.src;
      let blob = await fetch(src).then(res => res.blob());
      let url = URL.createObjectURL(blob);
      let noCorsVanillaImage = new Image();
      await new Promise(res => {
        noCorsVanillaImage.onload = res;
        noCorsVanillaImage.onerror = res;
        noCorsVanillaImage.src = url;
      });
      URL.revokeObjectURL(url);

      ctx.drawImage(noCorsVanillaImage, 0, 0);
      ctx.clearRect(0, 0, currentImage.naturalWidth, currentImage.naturalHeight);
      ctx.drawImage(currentImage, 0, 0);

      let croppedImage = new Image();
      await new Promise(res => {
        croppedImage.onload = res;
        croppedImage.onerror = res;
        croppedImage.src = canvas.toDataURL();
      });

      textures.push({ key, storagekey, url, currentImage, vanillaImage, croppedImage, status: 'size-mismatch' });
      continue;
    }

    textures.push({ key, storagekey, url, currentImage, vanillaImage, status: 'ok' });
  }

  return textures;
}

async function checkMusic(status) {
  status('music');
  let { music } = await browser.storage.local.get('music');
  if (!music) return { status: 'no-music' };
  let issues = [];

  for (let i = music.length-1; i >= 0; i--) {
    if (!music[i]) {
      issues.push(`Song #${i+1}: entry is null`);
      music.splice(i, 1);
      continue;
    }
    if (!music[i].metadata) {
      issues.push(`Song #${i+1}: metadata is missing`);
      music[i].metadata = { artist: 'reset', genre: 'CALM', jpartist: 'reset', jpname: 'reset', normalizeDb: 0, name: 'reset', source: 'reset', loop: false, loopStart: 0, loopLength: 0 };
    }
  }

  if (issues.length > 0) return { status: 'not-ok', issues, fixed: music };
  return { status: 'ok' };
}

async function checkSfx(status) {
  let { customSoundAtlas } = await browser.storage.local.get('customSoundAtlas');
  if (!customSoundAtlas) return { status: 'no-sfx' };


  let sprites = await importer.sfx.decodeDefaults(msg => status(msg));
  let baseKeys = sprites.map(sprite => sprite.name);
  let customKeys = Object.keys(customSoundAtlas);

  let difference = new Set(baseKeys);
  for (let key of customKeys)
    difference.delete(key);
  if (difference.size > 0)
    return { status: 'not-ok', missing: [...difference] }

  return { status: 'ok' };
}
