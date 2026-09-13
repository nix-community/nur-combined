<script setup>
import { ref, onMounted } from 'vue'
import Checkbox from '../../Checkbox.vue'
import SelectField from '../../SelectField.vue'
import TextField from '../../TextField.vue'

const props = defineProps({
  platform: String,
  config: Object,
  globalPrepCmd: Array,
  globalStateCmd: Array,
  serverCmd: Array
})

const config = ref(props.config)
const globalPrepCmd = ref(props.globalPrepCmd)
const globalStateCmd = ref(props.globalStateCmd)
const serverCmd = ref(props.serverCmd)

const cmds = ref({
  prep: globalPrepCmd,
  state: globalStateCmd
})

const prepCmdTemplate = {
  do: "",
  undo: "",
}

const serverCmdTemplate = {
  name: "",
  cmd: ""
}

const LOCALES = [
  ['bg', 'Български (Bulgarian)'],
  ['cs', 'Čeština (Czech)'],
  ['de', 'Deutsch (German)'],
  ['en', 'English'],
  ['en_GB', 'English, UK'],
  ['en_US', 'English, US'],
  ['es', 'Español (Spanish)'],
  ['fr', 'Français (French)'],
  ['hu', 'Magyar (Hungarian)'],
  ['it', 'Italiano (Italian)'],
  ['ja', '日本語 (Japanese)'],
  ['ko', '한국어 (Korean)'],
  ['pl', 'Polski (Polish)'],
  ['pt', 'Português (Portuguese)'],
  ['pt_BR', 'Português, Brasileiro (Portuguese, Brazilian)'],
  ['ru', 'Русский (Russian)'],
  ['sv', 'svenska (Swedish)'],
  ['tr', 'Türkçe (Turkish)'],
  ['uk', 'Українська (Ukranian)'],
  ['vi', 'Tiếng Việt (Vietnamese)'],
  ['zh', '简体中文 (Chinese Simplified)'],
  ['zh_TW', '繁體中文 (Chinese Traditional)'],
]

function addCmd(cmdArr, template, idx) {
  const _tpl = Object.assign({}, template);

  if (props.platform === 'windows') {
    _tpl.elevated = false;
  }
  if (idx < 0) {
    cmdArr.push(_tpl);
  } else {
    cmdArr.splice(idx, 0, _tpl);
  }
}

function removeCmd(cmdArr, index) {
  cmdArr.splice(index,1)
}

onMounted(() => {
  // Set default value for enable_pairing if not present
  if (config.value.enable_pairing === undefined) {
    config.value.enable_pairing = "enabled"
  }
})
</script>

<template>
  <div id="general" class="md-settings-group">
    <!-- Locale -->
    <SelectField
      id="locale"
      :label="$t('config.locale')"
      :supporting="$t('config.locale_desc')"
      v-model="config.locale"
    >
      <option v-for="[code, name] in LOCALES" :key="code" :value="code">{{ name }}</option>
    </SelectField>

    <!-- Helios Name -->
    <TextField
      id="sunshine_name"
      placeholder="Helios"
      :label="$t('config.sunshine_name')"
      :supporting="$t('config.sunshine_name_desc')"
      v-model="config.sunshine_name"
    />

    <!-- Log Level -->
    <SelectField
      id="min_log_level"
      :label="$t('config.min_log_level')"
      :supporting="$t('config.min_log_level_desc')"
      v-model="config.min_log_level"
    >
      <option v-for="n in 7" :key="n" :value="String(n - 1)">{{ $t(`config.min_log_level_${n - 1}`) }}</option>
    </SelectField>

    <!-- Global Prep/State Commands -->
    <div v-for="type in ['prep', 'state']" :key="type" :id="`global_${type}_cmd`" class="stack-sm">
      <div class="md-title-small">{{ $t(`config.global_${type}_cmd`) }}</div>
      <div class="md-body-small text-muted pre-wrap">{{ $t(`config.global_${type}_cmd_desc`) }}</div>
      <div class="md-table-scroll" v-if="cmds[type].length > 0">
        <table class="md-table">
          <thead>
            <tr>
              <th><Icon name="play_arrow" />{{ $t('_common.do_cmd') }}</th>
              <th><Icon name="undo" />{{ $t('_common.undo_cmd') }}</th>
              <th v-if="platform === 'windows'"><Icon name="shield" />{{ $t('_common.run_as') }}</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(c, i) in cmds[type]" :key="i">
              <td><TextField dense monospace :id="`${type}-do-${i}`" v-model="c.do" /></td>
              <td><TextField dense monospace :id="`${type}-undo-${i}`" v-model="c.undo" /></td>
              <td v-if="platform === 'windows'">
                <label class="md-checkbox">
                  <input type="checkbox" :id="`${type}-cmd-admin-${i}`" v-model="c.elevated" />
                  {{ $t('_common.elevated') }}
                </label>
              </td>
              <td>
                <div class="md-table__actions">
                  <button class="md-icon-button md-icon-button--danger" :aria-label="$t('_common.remove')" @click="removeCmd(cmds[type], i)">
                    <Icon name="delete" />
                  </button>
                  <button class="md-icon-button md-icon-button--tonal" :aria-label="$t('config.add')" @click="addCmd(cmds[type], prepCmdTemplate, i)">
                    <Icon name="add" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <button class="md-button md-button--tonal self-start" @click="addCmd(cmds[type], prepCmdTemplate, -1)">
        <Icon name="add" />{{ $t('config.add') }}
      </button>
    </div>

    <!-- Server Commands -->
    <div id="server_cmd" class="stack-sm">
      <div class="md-title-small">{{ $t('config.server_cmd') }}</div>
      <div class="md-body-small text-muted">
        {{ $t('config.server_cmd_desc') }}
        <a href="https://github.com/ClassicOldSong/Apollo/wiki/Server-Commands" target="_blank">
          {{ $t('_common.learn_more') }}
        </a>
      </div>
      <div class="md-table-scroll" v-if="serverCmd.length > 0">
        <table class="md-table">
          <thead>
            <tr>
              <th><Icon name="key" />{{ $t('_common.cmd_name') }}</th>
              <th><Icon name="terminal" />{{ $t('_common.cmd_val') }}</th>
              <th v-if="platform === 'windows'"><Icon name="shield" />{{ $t('_common.run_as') }}</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(c, i) in serverCmd" :key="i">
              <td><TextField dense :id="`server-cmd-name-${i}`" v-model="c.name" /></td>
              <td><TextField dense monospace :id="`server-cmd-val-${i}`" v-model="c.cmd" /></td>
              <td v-if="platform === 'windows'">
                <label class="md-checkbox">
                  <input type="checkbox" :id="'server-cmd-admin-' + i" v-model="c.elevated" />
                  {{ $t('_common.elevated') }}
                </label>
              </td>
              <td>
                <div class="md-table__actions">
                  <button class="md-icon-button md-icon-button--danger" :aria-label="$t('_common.remove')" @click="removeCmd(serverCmd, i)">
                    <Icon name="delete" />
                  </button>
                  <button class="md-icon-button md-icon-button--tonal" :aria-label="$t('config.add')" @click="addCmd(serverCmd, serverCmdTemplate, i)">
                    <Icon name="add" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <button class="md-button md-button--tonal self-start" @click="addCmd(serverCmd, serverCmdTemplate, -1)">
        <Icon name="add" />{{ $t('config.add') }}
      </button>
    </div>

    <div class="stack-sm">
      <!-- Enable Pairing -->
      <Checkbox id="enable_pairing" locale-prefix="config" v-model="config.enable_pairing" default="true"></Checkbox>
      <!-- Enable Discovery -->
      <Checkbox id="enable_discovery" locale-prefix="config" v-model="config.enable_discovery" default="true"></Checkbox>
      <!-- Notify Pre-Releases -->
      <Checkbox id="notify_pre_releases" locale-prefix="config" v-model="config.notify_pre_releases" default="false"></Checkbox>
      <!-- Enable system tray -->
      <Checkbox id="system_tray" locale-prefix="config" v-model="config.system_tray" default="true"></Checkbox>
      <!-- Anonymous telemetry -->
      <Checkbox id="telemetry_enabled" locale-prefix="config" v-model="config.telemetry_enabled" default="true"></Checkbox>
      <!-- Anonymous crash reporting -->
      <Checkbox id="crash_reporting_enabled" locale-prefix="config" v-model="config.crash_reporting_enabled" default="true"></Checkbox>
      <!-- Hide Tray Controls -->
      <Checkbox id="hide_tray_controls" locale-prefix="config" v-model="config.hide_tray_controls" default="false"></Checkbox>
    </div>
  </div>
</template>
