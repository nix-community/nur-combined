{ ... }:

{
  services.home-assistant.config = {
    script = {
      ir_fan_on_off.alias = "落地扇开关 IR";
      ir_fan_on_off.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xD81","DataLSB":"0xB081"}'';
      };
      ir_fan_plus.alias = "落地扇加 IR";
      ir_fan_plus.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xDC3","DataLSB":"0xB0C3"}'';
      };
      ir_fan_minus.alias = "落地扇减 IR";
      ir_fan_minus.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xDC6","DataLSB":"0xB063"}'';
      };
      ir_fan_swing.alias = "落地扇摇头 IR";
      ir_fan_swing.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xD90","DataLSB":"0xB009"}'';
      };
      ir_fan_mode.alias = "落地扇模式 IR";
      ir_fan_mode.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xD84","DataLSB":"0xB021"}'';
      };
      ir_ac_light.alias = "空调屏显 IR";
      ir_ac_light.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F509","DataLSB":"0x9DAF90"}'';
      };
      ir_ac_swing_v_on.alias = "空调上下摆风开 IR";
      ir_ac_swing_v_on.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F504","DataLSB":"0x9DAF20"}'';
      };
      ir_ac_swing_v_off.alias = "空调上下摆风关 IR";
      ir_ac_swing_v_off.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F505","DataLSB":"0x9DAFA0"}'';
      };
      ir_ac_swing_h_on.alias = "空调左右摆风开 IR";
      ir_ac_swing_h_on.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F507","DataLSB":"0x9DAFE0"}'';
      };
      ir_ac_swing_h_off.alias = "空调左右摆风关 IR";
      ir_ac_swing_h_off.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F508","DataLSB":"0x9DAF10"}'';
      };
      ir_tv_on_off.alias = "电视开关 IR";
      ir_tv_on_off.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x1818D02F","DataLSB":"0x18180BF4"}'';
      };
      ir_tv_input_source.alias = "电视信号源 IR";
      ir_tv_input_source.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x1818A857","DataLSB":"0x181815EA"}'';
      };
      ir_tv_left.alias = "电视左 IR";
      ir_tv_left.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x1818A659","DataLSB":"0x1818659A"}'';
      };
      ir_tv_right.alias = "电视右 IR";
      ir_tv_right.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x1818E619","DataLSB":"0x18186798"}'';
      };
      ir_tv_up.alias = "电视上 IR";
      ir_tv_up.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x181826D9","DataLSB":"0x1818649B"}'';
      };
      ir_tv_down.alias = "电视下 IR";
      ir_tv_down.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x18186699","DataLSB":"0x18186699"}'';
      };
      ir_tv_ok.alias = "电视确定 IR";
      ir_tv_ok.sequence = {
        service = "mqtt.publish";
        data.topic = "cmnd/tasmota_5E6E7B/IrSend";
        data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x181816E9","DataLSB":"0x18186897"}'';
      };
    };
    template = [
      {
        fan = [
          {
            default_entity_id = "fan.ir_fan";
            name = "格力落地扇";
            unique_id = "517d9c34-2f9c-4364-928f-b57449a71f5b";
            optimistic = true;
            turn_on.action = "script.ir_fan_on_off";
            turn_off.action = "script.ir_fan_on_off";
            set_oscillating.action = "script.ir_fan_swing";
          }
        ];
      }
      {
        switch = [
          {
            name = "空调屏显";
            unique_id = "db4fe1d1-c4d8-4218-bf1d-6353a933a3e3";
            optimistic = true;
            turn_on.action = "script.ir_ac_light";
            turn_off.action = "script.ir_ac_light";
          }
          {
            name = "空调上下摆风";
            unique_id = "8ccd543d-bca1-474e-8c0a-16268c1c8fc6";
            optimistic = true;
            turn_on.action = "script.ir_ac_swing_v_on";
            turn_off.action = "script.ir_ac_swing_v_off";
          }
          {
            name = "空调左右摆风";
            unique_id = "25cf3c50-0379-455b-ac13-c8b427f665e6";
            optimistic = true;
            turn_on.action = "script.ir_ac_swing_h_on";
            turn_off.action = "script.ir_ac_swing_h_off";
          }
          {
            name = "电视电源";
            unique_id = "e50aaea2-a3be-4898-939b-e0a3d74d7ac7";
            optimistic = true;
            turn_on.action = "script.ir_tv_on_off";
            turn_off.action = "script.ir_tv_on_off";
          }
        ];
      }
    ];
    climate = [
      {
        platform = "tasmota_irhvac";
        name = "美的空调";
        unique_id = "7798482a-d424-4824-a3ec-7a31e8d3d26f";

        command_topic = "cmnd/tasmota_5E6E7B/IRHVAC";
        state_topic = "stat/tasmota_5E6E7B/RESULT";
        availability_topic = "tele/tasmota_5E6E7B/LWT";

        temperature_sensor = "sensor.wo_shi_daikin_air_sensor_temperature_sensor";
        humidity_sensor = "sensor.wo_shi_daikin_air_sensor_humidity_sensor";

        vendor = "COOLIX";
        mqtt_delay = 0.0;

        min_temp = 16;
        max_temp = 30;
        target_temp = 26;
        initial_operation_mode = "off";
        away_temp = 24;
        precision = 1; # 0.5 fail to send

        supported_modes = [
          "off"
          "auto"
          "cool"
          "dry"
          "heat"
          "fan_only"
        ];

        supported_fan_speeds = [
          "auto" # Auto
          "min" # 20%
          "low" # 40%
          "medium" # 60%
          "high" # 80%
          "max" # 100%
        ];

        supported_swing_list = [
          "off"
          "vertical"
          "horizontal"
          "both"
        ];

        set_swingv = {
          "if".condition = "template";
          "if".value_template = "{{ swingv != 'off' }}";
          "then".action = "script.ir_ac_swing_v_on";
          "else".action = "script.ir_ac_swing_v_off";
        };

        set_swingh = {
          "if".condition = "template";
          "if".value_template = "{{ swingh != 'off' }}";
          "then".action = "script.ir_ac_swing_v_on";
          "else".action = "script.ir_ac_swing_h_off";
        };
      }
    ];
  };
}
