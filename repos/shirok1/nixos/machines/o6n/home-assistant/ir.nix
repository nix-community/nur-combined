{ ... }:

{
  services.home-assistant.config.homeassistant.packages.ir = {
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
            name = "电视电源";
            unique_id = "e50aaea2-a3be-4898-939b-e0a3d74d7ac7";
            optimistic = true;
            turn_on.action = "script.ir_tv_on_off";
            turn_off.action = "script.ir_tv_on_off";
          }
        ];
      }
    ];
  };
}
