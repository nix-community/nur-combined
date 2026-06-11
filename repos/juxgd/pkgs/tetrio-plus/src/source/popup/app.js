import OptionToggle from './components/OptionToggle.js'
import ThemeManager from './components/ThemeManager.js';
import SkinChanger from './components/SkinChanger.js';
import OtherSkinsChanger from './components/OtherSkinsChanger.js';
import SfxManager from './components/SfxManager.js';
import MusicManager from './components/MusicManager.js';
import BackgroundManager from './components/BackgroundManager.js';
import UrlPackLoader from './components/URLPackLoader.js';
import StyleEditor from './components/StyleEditor.js';
import '../shared/drop-handler.js';

const html = arg => arg.join(''); // NOOP, for editor integration.

const app = new Vue({
  template: html`
    <div id="app">
      <h1>
        TETR.IO PLUS
        <span class="version">
          v{{version}}<span v-if="commit" style="margin-left: 3px">({{ commit }})</span> | <a
            class="wiki"
            href="https://gitlab.com/UniQMG/tetrio-plus/wikis"
            @click="openSource($event)"
          >Wiki</a>
          <span v-if="debugMode">| Developer mode</span>
        </span>
      </h1>
      <p class="tagline">Unofficial TETR.IO Customization Tool</p>

      <fieldset class="section" v-if="isMobileExtensionPopup">
        <legend>Firefox mobile</legend>
        TETR.IO PLUS is currently runing on Firefox mobile in the extension popup.<br>
        All menu-opening buttons will open background tabs.<br>
        <button @click="openInNewTab()">Open this menu as a regular tab</button> instead to avoid this.
      </fieldset>

      <option-toggle storageKey="tetrioPlusEnabled" mode="hide">
        <fieldset class="section">
          <legend>TETR.IO PLUS disabled</legend>
          TETR.IO PLUS is disabled.<br>
          Enable it in the 'management' section below.
        </fieldset>
      </option-toggle>

      <!-- Update check result -->
      <template v-if="updateHref">
        <a href="#" @click.prevent="openInBrowser(updateHref)">
          {{ updateStatus }}
        </a>
      </template>
      <template v-else>{{ updateStatus }}</template>

      <!-- Main customization entries -->
      <option-toggle storageKey="tetrioPlusEnabled" mode="show">
        <fieldset class="section contentPackInfo" v-if="contentPack">
          <legend>Content Pack</legend>
          <div v-if="contentPackIssue" style="max-width: 400px">
            This page is attempting to use a remote content pack, but
            {{ contentPackIssue }}.
          </div>
          <div v-else>
            This page is using a remote content pack.<br>
            <a class="longLink" :href="contentPack">{{ contentPack }}</a><br>
            <button @click="openSettingsIO(contentPack)">Install this pack</button>
            <button @click="clearPack" v-if="isElectron">Stop</button>
          </div>
        </fieldset>

        <fieldset class="section">
          <legend>Block skins</legend>
          <skin-changer />
        </fieldset>
        <fieldset class="section">
          <legend>Other skins</legend>
          <other-skins-changer />
        </fieldset>
        <fieldset class="section">
          <legend>Sound effects</legend>
          <sfx-manager />
        </fieldset>
        <fieldset class="section">
          <legend>Music</legend>
          <music-manager />
        </fieldset>
        <fieldset class="section">
          <legend>Backgrounds</legend>
          <background-manager />
        </fieldset>
        <fieldset class="section">
          <legend>Custom features</legend>
          <option-toggle storageKey="enableAllSongTweaker">
            <span :title="(
              'Adds a field to the in-game music tweaker that allows you to ' +
              'set the occurance rate for all songs at once.'
            )">
              Enable 'All Songs' in music tweaker
            </span>
          </option-toggle>
          <div class="option-group">
            <option-toggle storageKey="enableCustomMaps">
              <span :title="(
                'Enables using custom maps for singleplayer. Open the editor ' +
                'and set the map string under solo -> custom -> meta.'
              )">
                Enable custom maps
              </span>
            </option-toggle>
            <div>
              <option-toggle inline storageKey="enableTouchControls">
                <span :title="(
                  'Allows you to control the game using touch inputs. Inputs ' +
                  'are mapped to two virtual joysticks on each side of the page. ' +
                  'Left up = harddrop, left down = softdrop, left left = move left ' +
                  'left right = move right. right up = 180 spin, right left = ccw ' +
                  'spin, right right = cw spin, right down = hold.'
                )">
                  Enable touch controls
                </span>
              </option-toggle>
              <option-toggle inline storageKey="enableTouchControls" mode="show">
                <button @click="openTouchEditor">Edit</button>
              </option-toggle>
              <option-toggle storageKey="enableEmoteTab">
                <span :title="(
                  'Shows an emote picker when pressing tab in chat'
                )">
                  Enable emote picker
                </span>
              </option-toggle>
            </div>
            <option-toggle storageKey="enableReplaySaver" @toggled="requestDownloadPermission()">
              <span title="Automatically downloads replays and saves them in \`~/Downloads/tetrio-plus-replays\`">
                Enable replay saver
              </span>
            </option-toggle>
            <option-toggle storageKey="enableOSD">
              <span :title="(
                'Shows what keys are pressed, for streaming or recording. ' +
                'Works on replays too!'
              )">
                Enable key OSD
              </span>
            </option-toggle>
            <option-toggle storageKey="enableOSD" mode="show">
              <option-toggle storageKey="useOldOSDIcons">
                Use old OSD icons
              </option-toggle>
            </option-toggle>
          </div>
        </fieldset>
        <fieldset class="section">
          <legend>Miscellaneous</legend>
          <div class="option-group">
            <url-pack-loader />

            <option-toggle storageKey="watermarkEnabled" mode="trigger" v-if="!debugMode" @trigger="enableDebugMode()"></option-toggle>
            <option-toggle storageKey="watermarkEnabled" v-if="debugMode">
              <span title="Shows a watermark in-game that indicates your usage of TETR.IO PLUS. This is in addition to the sigliatrip marker that the base game displays when it detects modifications.">
                Show extended modded watermark
              </span>
            </option-toggle>
            
            <option-toggle storageKey="bypassBootstrapper">
              <span :title="(
                'Disables integrity checks on the tetrio.js file and loads ' +
                'it directly. Fixes stacktraces but causes issues with ' +
                'game updates applying properly.'
              )">
                Bypass bootstrapper (deprecated)
              </span>
            </option-toggle>

            <option-toggle storageKey="openDevtoolsOnStart" v-if="isElectron">
              <span :title="(
                'Opens the developer tools as soon as the game launches. ' +
                'Works even if you can\\'t open them via hotkey'
              )">
                Open devtools automatically
              </span>
            </option-toggle>

            <option-toggle storageKey="hideTetrioPlusOnStartup" v-if="isElectron">
              <span :title="(
                'Hides this window on startup. You can press ctrl-t to reopen it.'
              )">
                Hide TETR.IO PLUS window on startup
              </span>
            </option-toggle>

            <option-toggle storageKey="forceIPCFetch" v-if="isElectron">
              <span :title="(
                'Makes all HTTP requests from the context of the main TETR.IO window instead of the main electron ' +
                'context.  Can help in some situations where responses are invalid (e.g. otherwise-undetected ' +
                'cloudflare interstitial) or truncated.'
              )">
                Force HTTP fetch over IPC fallback
              </span>
            </option-toggle>

            <option-toggle storageKey="disableSuppressExitPrompt" v-if="isElectron">
              <span title="TETR.IO PLUS by default disables the 'EXIT TETR.IO?' prompt. This option re-enables it.">
                Disable suppression of exit prompt
              </span>
            </option-toggle>

            <div v-if="isElectron">
              <option-toggle storageKey="enableUpdateCheck" @changed="updateCheck()">
                <span title="Notifies you if an update is available">
                  Enable update check
                </span>
              </option-toggle>
              <style-editor />
            </div>

            <option-toggle
              storageKey="debugBreakTheGame"
              mode="trigger"
              v-if="!debugMode"
              @trigger="enableDebugMode()"
            ></option-toggle>
            <option-toggle storageKey="debugBreakTheGame" v-if="debugMode">
              <span title="Has a minor chance of completely breaking the game 100% of the time">
                Break the game (May break the game)
              </span>
            </option-toggle>

            <div class="control-group" v-if="debugMode">
              <button @click="openStorageTool()" title="Opens storage tool">
                Open arbitrary storage writer tool
              </button>
            </div>
          </div>
        </fieldset>
      </option-toggle>


      <fieldset class="section">
        <legend>Management</legend>
        <div class="option-group">
          <option-toggle storageKey="tetrioPlusEnabled">
            <span :title="(
              'Toggles ALL FEATURES (that use request rewriting or injected scripts' +
              ', at least) on or off. Great for troubleshooting, but this is NOT ' +
              'AS GOOD AS UNINSTALLING TETR.IO PLUS.'
            )">
              TETR.IO PLUS enabled
            </span>
          </option-toggle>
          <theme-manager v-if="!isElectron" />
          <div v-if="isElectron && showUninstallerButton">
            <button @click="uninstall">Uninstall TETR.IO PLUS</button>
          </div>
          <div class="control-group">
            <button @click="openSettingsIO()" title="Opens the settings manager">
              Manage data / import TPSE
            </button>
            <button @click="openFixes()" title="Opens the quick fixes menu">
              Quick fixes
            </button>
            <button @click="openTemplates()" title="Opens the template list">
              Templates
            </button>
          </div>
        </div>
      </fieldset>

      <fieldset class="section" v-if="isElectron">
        <legend>Tweaks</legend>
        <div class="option-group">
          <option-toggle storageKey="windowTitleStatus" v-if="isElectron">
            <span title="Shows rich presence data in the TETR.IO window title.">
              Show status in window title
            </span>
          </option-toggle>
        </div>
      </fieldset>

      <!-- Footer -->
      <fieldset class="section legendless">
        <strong>Hard refresh (<kbd>ctrl-F5</kbd>) TETR.IO after making changes.</strong><br>
        <a href="https://gitlab.com/UniQMG/tetrio-plus" @click="openSource($event)">
          Source code and readme
        </a>
      </fieldset>
    </div>
  `,
  components: {
    OptionToggle,
    UrlPackLoader,
    ThemeManager,
    SkinChanger,
    OtherSkinsChanger,
    SfxManager,
    MusicManager,
    BackgroundManager,
    StyleEditor
  },
  data: {
    updateStatus: null,
    updateHref: null,
    debugMode: false,
    contentPack: null,
    allowURLPackLoader: null,
    whitelistedLoaderDomains: null,
    isMobileExtensionPopup: false,
    commit: null
  },
  computed: {
    isElectron() {
      return !!browser.electron;
    },
    showUninstallerButton() {
      return this.isElectron && browser.runtime.getManifest().browser_specific_settings.desktop_client.show_uninstaller_button;
    },
    version() {
      return browser.runtime.getManifest().version;
    },
    contentPackIssue() {
      if (!this.allowURLPackLoader)
        return 'remote pack loading by URL is not enabled';

      let url = new URL(this.contentPack);
      if (this.whitelistedLoaderDomains.indexOf(url.origin) == -1)
        return 'the domain (' + url.origin + ') isn\'t whitelisted';

      return null;
    }
  },
  async mounted() {
    if (await this.isMobileBrowser() && await this.isExtensionPopup()) {
      this.isMobileExtensionPopup = true;
    }

    let prefix = this.isElectron ? 'tetrio-plus-internal://resources/' : '../../../resources/';

    function fetchCommitFile(file) {
      return fetch(prefix + file)
        .then(res => res.text())
        .then(text => text.split('\n').filter(line => !line.startsWith('#')).join('').trim())
        .catch(ex => null)
    }
    const release_commit = await fetchCommitFile('release-commit');
    const previous_commit = await fetchCommitFile('ci-commit-previous');
    const override = await fetchCommitFile('override-commit');
    this.commit = override || ((release_commit != previous_commit) ? await fetchCommitFile('ci-commit') : null);

    let str = '';
    window.addEventListener('keydown', evt => {
      str = (str + evt.key).slice(-5);
      if (str == 'debug')
        this.enableDebugMode();
    });

    if (browser.tabs.query) {
      browser.tabs.query({
        active: true,
        windowId: browser.windows.WINDOW_ID_CURRENT
      }).then(tabs => {
        let port = browser.runtime.connect({ name: 'info-channel' });
        port.postMessage({ type: 'getUrlFromTab', tabId: tabs[0].id });
        port.onMessage.addListener(msg => {
          this.refreshContentPackInfo();
          if (msg.type != 'getUrlFromTabResult') return;
          let { useContentPack } = new URL(msg.url)
            .search
            .slice(1)
            .split('&')
            .map(e => e.split('='))
            .reduce((obj, [key, value]) => {
              obj[key] = value;
              return obj;
            }, {});
          if (!useContentPack) return;
          this.contentPack = decodeURIComponent(useContentPack);
        });
      })
    } else {
      // Use this syntax to avoid making the mdn verifier angery.
      // This is never called on firefox.
      let foo = browser.tabs;
      foo.electronOnMainNavigate(url => {
        this.refreshContentPackInfo();
        let match = /\?useContentPack=([^&]+)/.exec(url);
        if (!match) {
          this.contentPack = null;
          return;
        }
        this.contentPack = decodeURIComponent(match[1]);
      })
    }
    this.updateCheck();
  },
  methods: {
    async isMobileBrowser() {
      let { name } = await browser.runtime.getBrowserInfo();
      return name == 'Fennec';
    },
    async isExtensionPopup() {
      return await browser.tabs.getCurrent() == null;
    },
    async requestDownloadPermission() {
      if (!await browser.permissions.request({ permissions: ['downloads'] })) {
        await browser.storage.local.set({ enableReplaySaver: false });
        alert('Downloads permission not granted, replay saver disabled.');
      }
    },
    openInNewTab() {
      browser.tabs.create({ url: window.location.href, active: true });
      window.close();
    },
    openInBrowser(url) {
      window.openInBrowser(url)
    },
    refreshContentPackInfo() {
      browser.storage.local.get([
        'allowURLPackLoader',
        'whitelistedLoaderDomains'
      ]).then(cfg => {
        this.allowURLPackLoader = cfg.allowURLPackLoader;
        this.whitelistedLoaderDomains = cfg.whitelistedLoaderDomains || "";
      });
    },
    clearPack() {
      // Use this syntax to avoid making the mdn verifier angery.
      // This is never called on firefox.
      let foo = browser.tabs;
      foo.electronClearPack();
    },
    enableDebugMode() {
      console.log("Enabled debug mode")
      this.debugMode = true;
    },
    async openPanel(url, width=600, height=520) {
      if (await this.isMobileBrowser()) {
        browser.tabs.create({
          url: browser.extension.getURL(url),
          active: true
        });
      } else {
        browser.windows.create({
          type: 'detached_panel',
          url: browser.extension.getURL(url),
          width: width,
          height: height
        });
      }
    },
    async openSettingsIO(installUrl) {
      let url = 'source/panels/settingsImportExport/index.html';
      if (installUrl) url += '?install=' + encodeURIComponent(installUrl);
      await this.openPanel(url);
    },
    async openFixes() {
      await this.openPanel('source/panels/fixes/index.html', 1200, 720);
    },
    async openTemplates() {
      await this.openPanel('source/panels/templates/index.html', 600, 170);
    },
    openMonetizationInfo() {
      browser.windows.create({
        type: 'detached_panel',
        url: browser.extension.getURL(
          'source/panels/monetizationinfo/index.html'
        ),
        width: 750,
        height: 350
      });
    },
    openTouchEditor() {
      browser.tabs.create({
        url: browser.extension.getURL(
          'source/panels/touchcontroleditor/index.html'
        ),
        active: true
      });
    },
    openStorageTool() {
      browser.tabs.create({
        url: browser.extension.getURL(
          'source/panels/storagetool/index.html'
        ),
        active: true
      });
    },
    openSource(evt) {
      if (this.isElectron) {
        evt.preventDefault();
        openInBrowser(evt.target.href);
      }
    },
    uninstall() {
      browser.management.uninstallSelf().catch(ex => {
        alert(ex.toString());
      });
    },
    async updateCheck() {
      let res = await browser.storage.local.get('enableUpdateCheck');
      if (!res.enableUpdateCheck) {
        this.updateStatus = null;
        this.updateHref = null;
        return;
      }
      this.updateStatus = 'Checking for updates...';
      this.updateHref = null;

      function compare(version, target) {
        version = version.split('.').map(n => +n);
        target = target.split('.').map(n => +n);
        for (let i = 0; i < 3; i++) {
          if (version[i] > target[i]) return 1;
          if (version[i] < target[i]) return -1;
        }
        return 0;
      }

      try {
        const latest = await window.fetchGitlabReleasesJson();
        const regex = /^electron-v(\d+\.\d+\.\d+)-tetrio-v\d+$/;

        const target = regex.exec(latest[0].tag)[1];
        const version = this.version;
        if (compare(version, target) == -1) {
          this.updateStatus = 'Update available: ' + target;
          const baseUrl = 'https://gitlab.com/UniQMG/tetrio-plus/-/releases';
          this.updateHref = `${baseUrl}/${latest[0].tag}`;
        } else {
          this.updateStatus = 'Using latest version';
        }
      } catch(ex) {
        this.updateStatus = 'Failed to check for updates';
        console.error('Failed to check for updates:', ex);
      }
    }
  }
});

app.$mount('#app');
