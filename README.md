# fwPi

### Usage Examples
```bash
# Block google.com
sudo ./fwPIctl block-domain google.com

# Unblock google.com
sudo ./fwPIctl unblock-domain google.com

# Enable application_layer module (ID=20)
sudo ./fwPIctl module-enable application_layer 20

# Disable application_layer module
sudo ./fwPIctl module-disable application_layer 20

# Show current status
sudo ./fwPIctl status
```