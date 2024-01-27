# [cxadc](https://github.com/happycube/cxadc-linux3)
cxadc consists of a package (a kernel driver) and a module.

You can set device parameters using `cxadc.parameters.*.parameter`. This uses udev and may require `udevadm trigger` to reload.

Set the group the device belongs to with `group` to allow non-root access. This uses udev and may require `udevadm trigger` to reload.

Enable `exportVersionVariable`to have the environment variable `__CXADC_VERSION` set to the git hash.

## Example
```
{
    hardware.cxadc = {
        enable = true;
        group = "video";
        exportVersionVariable = true;

        parameters = {
            cxadc0 = {
                crystal = 40000000;
                level = 0;
                sixdb = false;
                tenbit = true;
                tenxfsc = 0;
                vmux = 1;
            }

            cxadc1 = {
                center_offset = -15;
                crystal = 40000000;
                level = 0;
                sixdb = false;
                tenbit = true;
                tenxfsc = 0;
                vmux = 1;
            }
        };
    };
}
```