const html = arg => arg.join(''); // NOOP, for editor integration.

import AudioEditor from './AudioEditor.js';
import AudioUploader from './AudioUploader.js';

export default {
  template: html`
    <div class="splittable-pane">
      <div class="listeditor">
        <audio-uploader class="listelement" @song="songUpload" />

        <template v-for="song of music">
          <div
            draggable="true"
            class="listelement song"
            :class="{ dragsongover: dragOver == song }"
            @drag="drag($event, song)"
            @dragleave="dragleave($event, song)"
            @dragover.prevent="dragover($event, song)"
            @drop="drop($event, song)"
          >
            <div class="handle">≡</div>
            <div class="name">
              <span class="name" :title="song.metadata.name">
                {{ song.metadata.name }}
              </span>
            </div>
            <div class="genre" :class="song.metadata.genre" @click="nextGenre(song)">
              {{ song.metadata.genre }}
            </div>
            <div class="artist">
              <span class="artist" :title="song.metadata.artist">
                {{ song.metadata.artist || '[no artist]' }}
              </span>
            </div>
            <div class="actions">
              <button @click="editing = song">Edit</button>
              <button @click="deleteSong(song)">Delete</button>
            </div>
          </div>

          <div class="editor inline" v-if="mobile && editing == song">
            <audio-editor @done="editing = null" :song="editing" :builtin="builtin"/>
          </div>
        </template>
      </div>
      <div class="editor-container" v-if="!mobile">
        <div class="editor">
          <audio-editor @done="editing = null" :song="editing" :builtin="builtin"/>
        </div>
      </div>
    </div>
  `,
  components: { AudioEditor, AudioUploader },
  props: ['music', 'builtin'],
  data: () => ({
    editing: null,
    mobile: false,
    dragOver: null,
    dragging: null
  }),
  mounted() {
    window.addEventListener('resize', () => this.recalcSize());
    this.recalcSize();
  },
  methods: {
    drag(event, song) {
      this.dragging = song;
    },
    dragover(event, song) {
      this.dragOver = song;
    },
    dragleave(event, song) {
      if (this.dragOver == song)
        this.dragOver = null;
    },
    drop(event, targetSong) {
      this.dragOver = null;
      let index = this.music.indexOf(targetSong);
      this.music.splice(this.music.indexOf(this.dragging), 1);
      this.music.splice(index, 0, this.dragging);
    },
    recalcSize() {
      this.mobile = window.innerWidth < 850;
    },
    songUpload(song) {
      this.music.push(song);
      this.save();
    },
    nextGenre(song) {
      switch (song.metadata.genre) {
        case      'CALM': song.metadata.genre =    'BATTLE'; break
        case    'BATTLE': song.metadata.genre =  'DISABLED'; break
        case  'DISABLED': song.metadata.genre =      'CALM'; break
      }
    },
    save() {
      this.$emit('save');
    },
    deleteSong(song) {
      this.$emit('deleteSong', song);
    }
  }
}
