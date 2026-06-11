const html = arg => arg.join(''); // NOOP, for editor integration.


export default {
  template: html`
    <div
      class="fileuploader"
      :class="{ draghover: hovering }"
      multiple
      @dragenter="dragEnter"
      @dragleave="dragLeave"
      @drop.prevent="drop"
      @click="$refs.fileupload.click()">
        {{ this.status || 'Upload music' }}
        <div class="tiny">click or drop files here - autosaves changes</div>
        <input
          type="file"
          style="display: none"
          ref="fileupload"
          multiple
          accept="audio/*"
          @change="change"
        />
    </div>
  `,
  data: () => ({
    hovering: false,
    status: null
  }),
  props: ['music'],
  methods: {
    dragEnter(evt) {
      if (evt.dataTransfer.items.length)
        this.hovering = true;
    },
    dragLeave(evt) {
      this.hovering = false;
    },
    drop(evt) {
      console.log("drop");
      console.log(evt, evt.dataTransfer);
      this.hovering = false;
      this.upload(files);
    },
    change(evt) {
      this.upload(this.$refs.fileupload.files);
    },
    randomId() {
      return new Array(16).fill(0).map(e => {
        return String.fromCharCode(97 + Math.floor(Math.random() * 26));
      }).join('');
    },
    async upload(files) {
      for (let [i, file] of Object.entries(files)) {
        console.log(file, i, files);
        this.status = `processing ${i} / ${files.length}...`
        let reader = new FileReader();
        reader.readAsDataURL(file, 'UTF-8');
        reader.onerror = evt => alert('Failed to load song ' + file.name);
        const evt = await new Promise(res => reader.onload = res);
        const songDataUrl = evt.target.result;

        let audio = new Audio();
        audio.src = URL.createObjectURL(file);
        audio.preload = 'auto';

        await new Promise(res => {
          audio.addEventListener('canplaythrough', res);
          audio.load();
        });

        if (!isFinite(audio.duration)) {
          alert('Failed to parse duration of song ' + file.name);
          continue;
        }

        let loopLength = Math.floor(audio.duration * 1000);
        console.log("Audio", audio, audio.duration);

        let readableName = file.name.replace(/\..+$/, '');
        let artist = '';
        // Set up artist when name is of the form "Artist - Song name"
        let match = /^(.+?)\s+-\s+(.+?)$/.exec(readableName);
        if (match) {
          artist = match[1];
          readableName = match[2];
        }
        // Remove extra underscores and dashes, and multiple spaces
        readableName = readableName.replace(/[-_]/g, ' ').replace(/\s+/g, ' ');

        const id = this.randomId();
        browser.storage.local.set({ ['song-' + id]: songDataUrl.toString() });

        this.$emit('song', {
          id: id,
          filename: file.name,
          override: null, // vanilla music overrides
          metadata: {
            name: readableName,
            jpname: readableName,
            artist: artist,
            jpartist: artist,
            genre: 'CALM',
            source: 'Custom song',
            loop: true,
            loopStart: 0,
            loopLength: loopLength,
            normalizeDb: 0,
            hidden: false
          }
        });
        console.log("check!");
      }
      this.status = null;
    }
  }
}
