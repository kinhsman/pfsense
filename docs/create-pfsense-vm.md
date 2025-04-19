## Step 1: Create VM:
   Edit the following values and then execute in Proxmox Shell:
   
   `<VM-ID>` - Example: `1000`
   
   `<STORAGE-ID>` - Example: `local-zfs`
   
   `<VM-NAME>` - Example: `pfsense`
### Create the VM with basic settings
```
qm create <VM-ID> \
  -agent 1 \
  -machine q35 \
  -tablet 0 \
  -localtime 1 \
  -bios ovmf \
  -cores 2 \
  -memory 8192 \
  -name <VM-NAME> \
  -net0 virtio,bridge=vmbr0 \
  -onboot 1 \
  -ostype other
```

### Allocate storage for EFI disk and boot disk
```
pvesm alloc <STORAGE-ID> <VM-ID> vm-<VM-ID>-disk-0 1M 1>&/dev/null
pvesm alloc <STORAGE-ID> <VM-ID> vm-<VM-ID>-disk-1 8G 1>&/dev/null
```

### Set additional VM configurations
```
qm set <VM-ID> \
  -efidisk0 <STORAGE-ID>:vm-<VM-ID>-disk-0,efitype=4m,pre-enrolled-keys=1,size=1M \
  -virtio0 <STORAGE-ID>:vm-<VM-ID>-disk-1,discard=on,iothread=1,size=8G \
  -boot order=virtio0 \
  -serial0 socket \
  -tags firewall \
  -vga qxl \
  -net1 virtio,bridge=vmbr1 >/dev/null
```

---

## Step 2: Download pfSense ISO and mount it to the VM
### Download the ISO file to Proxmox Storage:

[Download Mirrors](https://atxfiles.netgate.com/mirror/downloads/)

* Click on the Storage > ISO Images

* Paste the following URL and Download:

```
https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz
```
<img width="546" alt="image" src="https://github.com/user-attachments/assets/32b00046-a7dc-4a58-8c99-87bc12b1df1c" />
<img width="605" alt="image" src="https://github.com/user-attachments/assets/02515cef-551f-4db1-8669-89bb4f3d6711" />

### Mount the ISO to the VM

Open the VM settings > Hardware > Add CD/DVD Drive; then select the downloaded ISO
<img width="426" alt="image" src="https://github.com/user-attachments/assets/fdb3de0c-8046-44cf-8bcb-65958232f287" />

---
## Step 3: Start the VM

On the first boot, go into the boot settings and disable secure boot:

   * Hit `Esc` while the boot splash screen is visible
    
   * Select `Device Manager`
    
   * Select `Secure Boot Configuration`
    
   * Uncheck `Attempt Secure Boot`
    
   * Press `F10` to save
    
   * Press `Esc` to exit
    
   * Reset the VM

---
## Step 4: Initial configuration
### Complete the Setup Wizard

   * Set the LAN/WAN interface in the CLI on the first boot
   * Complete the Setup Wizard in the GUI as necessary
      * Temporarity allow GUI access via WAN interface:
        ```
        pfctl -d
        ```

### Enable Serial Console

To enable serial (xterm.js) console in Proxmox:

   * Navigate to System > Advanced, Admin Access tab
<img width="1142" alt="image" src="https://github.com/user-attachments/assets/da3bff1f-1605-4730-bdf5-b66212a78c0f" />

### Disable Hardware Offloading

To disable hardware checksum offload:

   * Navigate to System > Advanced, Networking tab

   * Locate the Networking Interfaces section

   * Check Disable hardware checksum offload

   * Click Save

   * Reboot the firewall from Diagnostics > Reboot or the console menu

![image](https://github.com/user-attachments/assets/47fd458d-b373-472a-b391-70916ea7dc7e)



