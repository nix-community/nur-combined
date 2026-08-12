# [cxadc](https://github.com/happycube/cxadc-linux3)
- Set device parameters using `cxadc.parameters.*.parameter`.  
- Set `group` to allow non-root access to the device and sysfs parameters.
- Enable `exportVersionVariable` to export the git hash to the environment variable `__CXADC_VERSION`.

>[!NOTE]
>Changes may require `udevadm trigger` to apply.

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