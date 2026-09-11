{ ... }:

{
  services.home-assistant.config.sensor =
    let
      snmpAP = {
        platform = "snmp";
        host = "192.168.88.116";
        version = "3";
        username = "!env_var HUAWEI_AP_SNMP_USERNAME";
        auth_key = "!env_var HUAWEI_AP_SNMP_AUTH_KEY";
        auth_protocol = "hmac192-sha256";
        priv_key = "!env_var HUAWEI_AP_SNMP_PRIV_KEY";
        priv_protocol = "aes-cfb-256";
        accept_errors = true;
      };

      apIndex = "232.215.101.161.219.224"; # e8:d7:65:a1:db:e0
      apOid = column: "1.3.6.1.4.1.2011.6.139.13.3.3.1.${toString column}.${apIndex}";
      radioOid =
        column: radio: "1.3.6.1.4.1.2011.6.139.16.1.2.1.${toString column}.${apIndex}.${toString radio}";
      mkSensor = sensor: snmpAP // sensor;
    in
    [
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW Status";
        unique_id = "huawei_ap_status";
        baseoid = apOid 6;
        icon = "mdi:access-point-network";
        value_template = "{% set states = {1: 'idle', 2: 'autofind', 3: 'type_mismatch', 4: 'fault', 5: 'configuring', 6: 'config_failed', 7: 'download', 8: 'normal', 9: 'committing', 10: 'commit_failed', 11: 'standby', 12: 'version_mismatch', 13: 'name_conflict', 14: 'invalid', 15: 'country_code_mismatch'} %} {{ states.get(value | int, 'unknown_' ~ value) }}";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW Uptime";
        unique_id = "huawei_ap_uptime";
        baseoid = apOid 18;
        device_class = "duration";
        unit_of_measurement = "s";
        state_class = "measurement";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW CPU Usage";
        unique_id = "huawei_ap_cpu_usage";
        baseoid = apOid 41;
        unit_of_measurement = "%";
        state_class = "measurement";
        icon = "mdi:cpu-64-bit";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW Memory Usage";
        unique_id = "huawei_ap_memory_usage";
        baseoid = apOid 40;
        unit_of_measurement = "%";
        state_class = "measurement";
        icon = "mdi:memory";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW Temperature";
        unique_id = "huawei_ap_temperature";
        baseoid = apOid 43;
        device_class = "temperature";
        unit_of_measurement = "°C";
        state_class = "measurement";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW Clients";
        unique_id = "huawei_ap_clients";
        baseoid = apOid 44;
        state_class = "measurement";
        icon = "mdi:wifi";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW Firmware";
        unique_id = "huawei_ap_firmware";
        baseoid = apOid 7;
        icon = "mdi:chip";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW Uplink Rate";
        unique_id = "huawei_ap_uplink_rate";
        baseoid = apOid 54;
        device_class = "data_rate";
        unit_of_measurement = "kbit/s";
        state_class = "measurement";
        icon = "mdi:upload-network";
      })

      # Radio 0: 2.4 GHz
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 2.4 GHz Clients";
        unique_id = "huawei_ap_radio_24_clients";
        baseoid = radioOid 40 0;
        state_class = "measurement";
        icon = "mdi:wifi";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 2.4 GHz Channel";
        unique_id = "huawei_ap_radio_24_channel";
        baseoid = radioOid 7 0;
        icon = "mdi:radio-tower";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 2.4 GHz Channel Utilization";
        unique_id = "huawei_ap_radio_24_channel_utilization";
        baseoid = radioOid 25 0;
        unit_of_measurement = "%";
        state_class = "measurement";
        icon = "mdi:chart-donut";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 2.4 GHz Noise";
        unique_id = "huawei_ap_radio_24_noise";
        baseoid = radioOid 24 0;
        device_class = "signal_strength";
        unit_of_measurement = "dBm";
        state_class = "measurement";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 2.4 GHz Average Client Signal";
        unique_id = "huawei_ap_radio_24_average_client_signal";
        baseoid = radioOid 41 0;
        device_class = "signal_strength";
        unit_of_measurement = "dBm";
        state_class = "measurement";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 2.4 GHz Receive Rate";
        unique_id = "huawei_ap_radio_24_receive_rate";
        baseoid = radioOid 32 0;
        device_class = "data_rate";
        unit_of_measurement = "kbit/s";
        state_class = "measurement";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 2.4 GHz Send Rate";
        unique_id = "huawei_ap_radio_24_send_rate";
        baseoid = radioOid 37 0;
        device_class = "data_rate";
        unit_of_measurement = "kbit/s";
        state_class = "measurement";
      })

      # Radio 1: 5 GHz
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 5 GHz Clients";
        unique_id = "huawei_ap_radio_5_clients";
        baseoid = radioOid 40 1;
        state_class = "measurement";
        icon = "mdi:wifi";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 5 GHz Channel";
        unique_id = "huawei_ap_radio_5_channel";
        baseoid = radioOid 7 1;
        icon = "mdi:radio-tower";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 5 GHz Channel Utilization";
        unique_id = "huawei_ap_radio_5_channel_utilization";
        baseoid = radioOid 25 1;
        unit_of_measurement = "%";
        state_class = "measurement";
        icon = "mdi:chart-donut";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 5 GHz Noise";
        unique_id = "huawei_ap_radio_5_noise";
        baseoid = radioOid 24 1;
        device_class = "signal_strength";
        unit_of_measurement = "dBm";
        state_class = "measurement";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 5 GHz Average Client Signal";
        unique_id = "huawei_ap_radio_5_average_client_signal";
        baseoid = radioOid 41 1;
        device_class = "signal_strength";
        unit_of_measurement = "dBm";
        state_class = "measurement";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 5 GHz Receive Rate";
        unique_id = "huawei_ap_radio_5_receive_rate";
        baseoid = radioOid 32 1;
        device_class = "data_rate";
        unit_of_measurement = "kbit/s";
        state_class = "measurement";
      })
      (mkSensor {
        name = "Huawei AirEngine 5762-15HW 5 GHz Send Rate";
        unique_id = "huawei_ap_radio_5_send_rate";
        baseoid = radioOid 37 1;
        device_class = "data_rate";
        unit_of_measurement = "kbit/s";
        state_class = "measurement";
      })
    ];
}
