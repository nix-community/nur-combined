#!/usr/bin/env python3

import oqpsk_sniffer, sys, SoapySDR, urllib.parse
from SoapySDR import SOAPY_SDR_RX

def augmented_parser():
    parser = oqpsk_sniffer.argument_parser()

    # Create wireshark extcap options
    # From [extcap_example.py](https://github.com/wireshark/wireshark/blob/master/doc/extcap_example.py)
    parser.add_argument("--extcap-interfaces", dest="extcap_interfaces", help="Provide a list of interfaces to capture from", action="store_true")
    parser.add_argument("--extcap-interface", dest="extcap_interface", help="Provide the interface to capture from")
    parser.add_argument("--extcap-dlts", dest="extcap_dlts", help="Provide a list of dlts for the given interface", action="store_true")
    parser.add_argument("--extcap-config", dest="extcap_config", help="Provide a list of configurations for the given interface", action="store_true")
    parser.add_argument("--extcap-version", dest="extcap_version", help="Provide the wireshark version being used")
    parser.add_argument("--capture", dest="capture", help="", action="store_true")
    parser.add_argument("--fifo", dest="output", type=str)
    return parser

class DeviceRef:
    def __init__(self, args):
        self.args = args
    
    def display(self):
        return self.args['label']

    def short_name(self):
        return f"{self.args['driver']}-{self.args['serial']}"
    
    def soapy_args(self):
        return f"driver={self.args['driver']},serial={self.args['serial']}"
    
    def open(self):
        return SoapySDR.Device(self.args)
    
    @staticmethod
    def from_device(dev):
        return DeviceRef(dict(dev))

def extcap_version():
    print("extcap {version=1.0}{display=IEEE 802.15.4}")

def extcap_interfaces():
    for dev in SoapySDR.Device.enumerate():
        dev = DeviceRef.from_device(dev)
        print("interface {value=%s}{display=802.15.4: %s}" % (dev.short_name(), dev.display()))

def extcap_dlts():
    print("dlt {number=195}{name=LINKTYPE_IEEE802_15_4_WITHFCS}{display=IEEE 802.15.4 with FCS}")

def extcap_config(interface):
    mapping = { DeviceRef.from_device(d).short_name(): DeviceRef.from_device(d) for d in SoapySDR.Device.enumerate() }
    dev = mapping[interface].open()

    args = []
    args.append((0, '--antenna', 'Antenna', 'RX Antenna', 'integer', '{type=selector}'))
    args.append((1, '--channel', 'Channel', 'Channel to receive on', 'integer', '{type=selector}'))
    args.append((2, '--gain', 'Gain', 'RX Gain', 'double', '{default=50.0}'))

    values = []
    # Add antennas
    for i, antenna in enumerate(dev.listAntennas(SOAPY_SDR_RX, 0)):
        values.append((0, antenna, antenna, 'false'))

    # Add channels
    for i in range(11, 27):
        values.append((1, i, i, 'false'))

    for arg in args:
        print("arg {number=%d}{call=%s}{display=%s}{tooltip=%s}{type=%s}%s" % arg)

    for value in values:
        print("value {arg=%d}{value=%s}{display=%s}{default=%s}" % value)

def main():
    options = augmented_parser().parse_args()
    if options.extcap_interfaces:
        extcap_version()
        extcap_interfaces()
        sys.exit(0)
    elif options.extcap_config:
        extcap_version()
        extcap_config(options.extcap_interface)
        sys.exit(0)
    elif options.extcap_dlts:
        extcap_version()
        extcap_dlts()
        sys.exit(0)

    if options.extcap_interface != '':
        mapping = { DeviceRef.from_device(d).short_name(): DeviceRef.from_device(d).soapy_args() for d in SoapySDR.Device.enumerate() }
        options.device_args = mapping[options.extcap_interface]
        del options.extcap_version
        del options.extcap_interface
        del options.capture

    oqpsk_sniffer.main(options=options)

if __name__ == '__main__':
    main()