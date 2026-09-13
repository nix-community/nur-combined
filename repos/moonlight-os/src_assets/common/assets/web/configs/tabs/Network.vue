<script setup>
import { computed, ref } from 'vue'
import Banner from "../../Banner.vue";
import Checkbox from "../../Checkbox.vue";
import SelectField from "../../SelectField.vue";
import TextField from "../../TextField.vue";

const props = defineProps([
  'platform',
  'config'
])

const defaultMoonlightPort = 47989

const config = ref(props.config)
const effectivePort = computed(() => +config.value?.port ?? defaultMoonlightPort)
const quicEnabled = computed(() =>
  [true, 1, 'true', '1', 'enabled', 'enable', 'yes', 'on'].includes(config.value?.enable_quic)
)
</script>

<template>
  <div id="network" class="md-settings-group">
    <!-- Moonlight OS QUIC transport -->
    <Checkbox id="enable_quic" locale-prefix="config" v-model="config.enable_quic" default="false"></Checkbox>
    <Banner variant="warning" v-if="quicEnabled">
      {{ $t('config.enable_quic_warning') }}
    </Banner>

    <!-- UPnP -->
    <Checkbox id="upnp" locale-prefix="config" v-model="config.upnp" default="false"></Checkbox>

    <!-- Address family -->
    <SelectField
      id="address_family"
      :label="$t('config.address_family')"
      :supporting="$t('config.address_family_desc')"
      v-model="config.address_family"
    >
      <option value="ipv4">{{ $t('config.address_family_ipv4') }}</option>
      <option value="both">{{ $t('config.address_family_both') }}</option>
    </SelectField>

    <!-- Port -->
    <div class="stack-sm">
      <TextField
        id="port"
        type="number"
        min="1029"
        max="65514"
        :placeholder="String(defaultMoonlightPort)"
        :label="$t('config.port')"
        :supporting="$t('config.port_desc')"
        v-model="config.port"
      />

      <!-- Add warning if any port is less than 1024 -->
      <Banner variant="error" v-if="(+effectivePort - 5) < 1024">{{ $t('config.port_alert_1') }}</Banner>
      <!-- Add warning if any port is above 65535 -->
      <Banner variant="error" v-if="(+effectivePort + 21) > 65535">{{ $t('config.port_alert_2') }}</Banner>

      <!-- Every port Helios derives from the base port. -->
      <div class="md-table-scroll">
        <table class="md-table">
          <thead>
            <tr>
              <th>{{ $t('config.port_protocol') }}</th>
              <th>{{ $t('config.port_port') }}</th>
              <th>{{ $t('config.port_note') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <!-- HTTPS -->
              <td>{{ $t('config.port_tcp') }}</td>
              <td class="monospace">{{+effectivePort - 5}}</td>
              <td></td>
            </tr>
            <tr>
              <!-- HTTP -->
              <td>{{ $t('config.port_tcp') }}</td>
              <td class="monospace">{{+effectivePort}}</td>
              <td>
                <Banner variant="info" v-if="+effectivePort !== defaultMoonlightPort">
                  {{ $t('config.port_http_port_note') }}
                </Banner>
              </td>
            </tr>
            <tr>
              <!-- Web UI -->
              <td>{{ $t('config.port_tcp') }}</td>
              <td class="monospace">{{+effectivePort + 1}}</td>
              <td>{{ $t('config.port_web_ui') }}</td>
            </tr>
            <tr>
              <!-- RTSP -->
              <td>{{ $t('config.port_tcp') }}</td>
              <td class="monospace">{{+effectivePort + 21}}</td>
              <td></td>
            </tr>
            <tr>
              <!-- Video, Control, Audio, Microphone -->
              <td>{{ $t('config.port_udp') }}</td>
              <td class="monospace">{{+effectivePort + 9}} &ndash; {{+effectivePort + 12}}</td>
              <td></td>
            </tr>
            <tr v-if="quicEnabled">
              <!-- Highly experimental Moonlight OS QUIC -->
              <td>{{ $t('config.port_udp') }}</td>
              <td class="monospace">{{+effectivePort + 14}}</td>
              <td>{{ $t('config.port_quic_experimental') }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- add warning about exposing web ui to the internet -->
      <Banner variant="warning" v-if="config.origin_web_ui_allowed === 'wan'">{{ $t('config.port_warning') }}</Banner>
    </div>

    <!-- Origin Web UI Allowed -->
    <SelectField
      id="origin_web_ui_allowed"
      :label="$t('config.origin_web_ui_allowed')"
      :supporting="$t('config.origin_web_ui_allowed_desc')"
      v-model="config.origin_web_ui_allowed"
    >
      <option value="pc">{{ $t('config.origin_web_ui_allowed_pc') }}</option>
      <option value="lan">{{ $t('config.origin_web_ui_allowed_lan') }}</option>
      <option value="wan">{{ $t('config.origin_web_ui_allowed_wan') }}</option>
    </SelectField>

    <!-- External IP -->
    <TextField
      id="external_ip"
      placeholder="123.456.789.12"
      :label="$t('config.external_ip')"
      :supporting="$t('config.external_ip_desc')"
      v-model="config.external_ip"
    />

    <!-- LAN Encryption Mode -->
    <SelectField
      id="lan_encryption_mode"
      :label="$t('config.lan_encryption_mode')"
      :supporting="$t('config.lan_encryption_mode_desc')"
      v-model="config.lan_encryption_mode"
    >
      <option value="0">{{ $t('_common.disabled_def') }}</option>
      <option value="1">{{ $t('config.lan_encryption_mode_1') }}</option>
      <option value="2">{{ $t('config.lan_encryption_mode_2') }}</option>
    </SelectField>

    <!-- WAN Encryption Mode -->
    <SelectField
      id="wan_encryption_mode"
      :label="$t('config.wan_encryption_mode')"
      :supporting="$t('config.wan_encryption_mode_desc')"
      v-model="config.wan_encryption_mode"
    >
      <option value="0">{{ $t('_common.disabled') }}</option>
      <option value="1">{{ $t('config.wan_encryption_mode_1') }}</option>
      <option value="2">{{ $t('config.wan_encryption_mode_2') }}</option>
    </SelectField>

    <!-- Ping Timeout -->
    <TextField
      id="ping_timeout"
      placeholder="10000"
      :label="$t('config.ping_timeout')"
      :supporting="$t('config.ping_timeout_desc')"
      v-model="config.ping_timeout"
    />
  </div>
</template>
