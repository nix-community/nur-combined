import importer from '../../importers/import.js';
const html = arg => arg.join(''); // NOOP, for editor integration.

const app = new Vue({
  template: html`
    <!-- Error screen -->
    <div v-if="error">
      <h1>Error</h1>
      <pre>{{ error }}</pre>
      Try updating your plugin
    </div>

    <!-- Preload -->
    <div v-else-if="loading">
      <em>Please wait...</em>
    </div>

    <!-- Editor -->
    <div v-else>
      <div v-if="decodeStatus">
        Status: {{ decodeStatus }}...<br>
      </div>
      <div v-else-if="encoding">
        Encoding new sfx file...
      </div>
      <div v-else>
        <fieldset>
          <legend>Save changes</legend>
          <button @click="save">Re-encode and save changes</button><br>
          This may freeze your browser for a bit.
          <div v-if="encodeResult">
            Encode completed. Result:<br>
            <audio :src="encodeResult" controls></audio>
          </div>
        </fieldset>
        <fieldset>
          <legend>Replace multiple by filename</legend>
          <em>Filename up to the first dot must match the sound effect name.</em><br>
          <input type="file" @change="replaceMultiple($event)" accept="audio/*" multiple/>
          <details>
            <summary>Advanced</summary>
            <div>Filename parsing regex</div>
            <div><input type="text" v-model="filenameParseRegex"></div>
            <div>First capture group will determine sound effect name</div>
            <code style="color: red" v-if="regexError">{{ regexError }}</code>
          </details>
        </fieldset>
        <fieldset>
          <legend>Decompile and load current soundpack</legend>
          This will take your current sound effects configuration and load it here.
          <p>
            This is not recommended because of re-encode quality loss issues. Each time you
            re-encode sound effects, some information is discarded due to encoding as lossy <code>.ogg</code>.
            Only use this option if you don't have access to the original sfx files.
          </p>
          <p>
            To iterate on soundpacks, you should rename your sound effects and keep them in a
            dedicated folder, and then use the <code>replace multiple by filename</code> tool instead.
          </p>
          <p>
            Note that this option cannot tell the difference between an unmodified original
            base game sound effect and a custom one. All decompiled files will be marked as
            <code>current</code>.
          </p>
          <button @click="decompileCurrent()">Decompile and load current soundpack</button>
        </fieldset>
        <fieldset>
          <legend>Export currently loaded sounds</legend>
          This will take the sounds currently loaded into the sfx editor and export them
          as a zip file. This is <em>not</em> your currently saved configuration (to export
          that, use the <code>Decompile and load current soundpack</code> option first).<br>

          <input type="checkbox" v-model.boolean="includeSourceInExportFilenames"></input>
          include source in exported filenames<br>

          <button @click="exportZip()">Export currently loaded sounds</button><br>

          This may freeze your browser for a bit.
        </fieldset>
      </div>

      <fieldset>
        <legend>TPSE files</legend>
        You can import <code>.tpse</code> files through the
        <code>Manage data/Import TPSE</code> submenu accessible from the main
        TETR.IO PLUS menu.
        The sfx editor is only for creating sound packs from unpacked audio
        files (<code>.wav</code>, <code>.ogg</code>, etc.)
      </fieldset>

      <fieldset v-for="sprite of sprites">
        <legend>{{ sprite.name }}</legend>
        <div v-if="sprite.error" :title="sprite.error">
          Encountered an error while encoding this sprite.
          This sprite must be replaced or else it will be empty.<br>
          <button @click="sprite.showError = !sprite.showError">
            Show/hide
          </button>
          <pre v-if="sprite.showError">{{ sprite.error }}</pre>
        </div>
        <button @click="play(sprite)">Play</button>
        (source: <code>{{ sprite.source }}</code>, duration: <code>{{ sprite.duration.toFixed(3) }}s</code><!--
        --><span v-if="sprite.source == 'base'">, offset: <code>{{ sprite.offset.toFixed(3) }}s</code></span>)

        <br>

        Replace:
        <input type="file" @change="replace($event, sprite)" accept="audio/*"/>
      </fieldset>
    </div>
  `,
  data: {
    error: null,

    loading: true,

    decodeStatus: "",

    filenameParseRegex: "^([^.]+)",

    loadedCurrent: false,

    includeSourceInExportFilenames: false,

    encoding: false,
    encodeResult: null,

    audioContext: null,

    sprites: [],
  },
  async mounted() {
    this.loading = false;
    this.audioContext = new AudioContext();
    this.decode();
  },
  computed: {
    regexError() {
      try {
        new RegExp(this.filenameParseRegex)
        return null;
      } catch(ex) {
        return ex.toString();
      }
    },
    parsedFilenameParseRegex() {
      try {
        return new RegExp(this.filenameParseRegex);
      } catch(ex) {
        return null;
      }
    }
  },
  methods: {
    play(sprite) {
      let source = this.audioContext.createBufferSource();
      source.connect(this.audioContext.destination);
      source.buffer = sprite.buffer;
      source.start();
    },

    async save() {
      let message = 'Please confirm that you\'re ready to overwrite your current configuration.';
      if (!this.loadedCurrent)
        message += '\n⚠ You have not loaded your current sound effects. This will wipe out any existing configuration you have.';
      if (!confirm(message)) return;
      if (!this.sprites.some(sprite => sprite.source == 'modified'))
        if (!confirm('Are you absolutely sure? No sounds have been modified!'))
          return;


      this.encodeResult = null;
      this.encoding = true;
      await new Promise(res => this.$nextTick(res));
      this.encodeResult = await importer.sfx.encode(
        this.sprites,
        browser.storage.local
      );
      this.encoding = false;
    },

    async replace(evt, sprite) {
      let file = evt.target.files[0];
      if (!file) return;

      let reader = new FileReader();
      await new Promise(res => {
        reader.addEventListener('load', res);
        reader.readAsArrayBuffer(file);
      });

      sprite.buffer = await importer.sfx.decodeAudio(reader.result);
      sprite.duration = sprite.buffer.duration;
      sprite.offset = -1;
      sprite.source = 'modified';

      console.log("Sprite buffer replaced", sprite.buffer);

      // reset the handler
      evt.target.type = '';
      evt.target.type = 'file';
    },

    async replaceMultiple(evt) {
      let replaced = [];
      for (let file of evt.target.files) {
        let spriteNameMatch = this.parsedFilenameParseRegex.exec(file.name);
        if (!spriteNameMatch) {
          replaced.push(`FAILED: Regex failed to match "${file.name}"`);
          continue;
        }

        let spriteName = spriteNameMatch[1];
        let sprite = this.sprites.filter(sprite => sprite.name == spriteName)[0];
        if (!sprite) {
          replaced.push(`FAILED: Unknown sound effect ${spriteName}`)
          continue;
        }

        let reader = new FileReader();
        await new Promise(res => {
          reader.addEventListener('load', res);
          reader.readAsArrayBuffer(file);
        });

        let sfxBuffer = await importer.sfx.decodeAudio(reader.result);
        sprite.buffer = sfxBuffer;
        sprite.duration = sprite.buffer.duration;
        sprite.offset = -1;
        sprite.source = 'modified';

        replaced.push(`Success: ${file.name} -> ${spriteName}`)
      }
      alert(replaced.join('\n'));
      // reset the handler
      evt.target.type = '';
      evt.target.type = 'file';
    },

    async exportZip() {
      let zip = new JSZip();
      for (let { name, offset, duration, buffer, source } of this.sprites) {
        this.decodeStatus = `working on export: encoding ${name}.ogg...`;
        await new Promise(res => setTimeout(res, 1));

        let encoder = new window.OggVorbisEncoder(buffer.sampleRate, buffer.numberOfChannels, 1.0);

        let channels = [];
        for (let i = 0; i < buffer.numberOfChannels; i++)
          channels.push(buffer.getChannelData(i));
        encoder.encode(channels);

        let filename = this.includeSourceInExportFilenames
          ? `${name}.${source}.ogg`
          : `${name}.ogg`;
        let blob = encoder.finish();
        zip.file(filename, blob);
      }

      let source = 'tetrio-plus';
      if (this.sprites.every(sprite => sprite.source == 'base')) source = 'base-tetrio';
      if (this.sprites.every(sprite => sprite.source == 'current')) source = 'tetrio-plus-current';
      if (this.sprites.some(sprite => sprite.source == 'modified')) source = 'tetrio-plus-modified';

      this.decodeStatus = `working on export: generating zipfile...`;
      let blob = await zip.generateAsync({ type: 'blob' });

      let a = document.createElement('a');
      a.setAttribute('href', URL.createObjectURL(blob));
      a.setAttribute('download', `${source}-sfx-export.zip`);
      a.style.display = 'none';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      this.decodeStatus = null;
    },

    async decompileCurrent() {
      let { customSoundAtlas, customSounds } = await browser.storage.local.get([
        'customSoundAtlas', 'customSounds'
      ]);
      if (!customSoundAtlas || !customSounds) {
        alert('No custom sfx configured.');
        return;
      }
      this.decodeStatus = 'Decompiling...';

      let ctx = new window.OfflineAudioContext(2, 44100, 44100);
      let soundBuffer = await ctx.decodeAudioData(await (await fetch(customSounds)).arrayBuffer());

      for (let [name, [ offset, duration ]] of Object.entries(customSoundAtlas)) {
        this.decodeStatus = `Decompiling: slicing ${name}.ogg...`;

        offset /= 1000; duration /= 1000; // Convert milliseconds to seconds

        const ctx = new window.OfflineAudioContext(2, 44100*duration, 44100);

        let source = ctx.createBufferSource();
        source.buffer = soundBuffer;
        source.connect(ctx.destination);
        source.start(0, offset, duration);

        let sprite = this.sprites.filter(sprite => sprite.name == name)[0];
        if (!sprite) {
          console.warn('failed to find sound effect:', sprite);
        } else {
          sprite.buffer = await ctx.startRendering();
          sprite.source = 'current';
          sprite.duration = duration;
        }
      }

      this.decodeStatus = null;
      this.loadedCurrent = true;
    },

    async decode() {
      try {
        this.decodeStatus = "Starting";

        // Set sfx enabled flag temporarily, to fetch only the base game content.
        let { sfxEnabled } = await browser.storage.local.get('sfxEnabled');
        await browser.storage.local.set({ sfxEnabled: false });

        let sprites = await importer.sfx.decodeDefaults(msg => this.decodeStatus = msg);
        for (let sprite of sprites) {
          this.sprites.push({
            ...sprite,
            source: 'base' // 'current' | 'modified'
          });
        }

        // Reset the sfx enabled flag since we're now done fetching data
        await browser.storage.local.set({ sfxEnabled });

        this.decodeStatus = null;
        this.decoding = false;
      } catch(ex) {
        this.error = ex;
        console.error(ex);
      } finally {
        this.decodeStatus = null;
      }
    }
  }
});

window.app = app;
app.$mount('#app');
