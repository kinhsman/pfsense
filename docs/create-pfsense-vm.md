
# Creating a pfSense VM in Proxmox using UEFI boot

This guide provides step-by-step instructions for setting up a pfSense virtual machine (VM) on a Proxmox VE server using UEFI boot. This will allow admin to interact (copy/paste) with the pfsense console directly from proxmox without having to SSH to the box. It covers VM creation, ISO mounting, initial boot configuration, and essential pfSense settings.

---

## Step 1: Create the pfSense VM

### 1.1 Define VM Parameters

Before executing the commands, define the following values:

- **`<VM-ID>`**: A unique ID for the VM (e.g., `1000`).
- **`<STORAGE-ID>`**: The storage location for VM disks (e.g., `local-zfs`).
- **`<VM-NAME>`**: A descriptive name for the VM (e.g., `pfsense`).

### 1.2 Create the VM with Basic Settings

Adjust the value to suit your need, and then run the following command in the Proxmox shell to create the VM with optimized settings for pfSense:

```bash
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

**Explanation**:
- `-agent 1`: Enables QEMU guest agent for better integration.
- `-machine q35`: Uses a modern machine type for UEFI support.
- `-bios ovmf`: Configures UEFI firmware.
- `-cores 2`: Assigns 2 CPU cores.
- `-memory 8192`: Allocates 8GB of RAM.
- `-net0 virtio,bridge=vmbr0`: Configures the WAN interface using VirtIO.
- `-onboot 1`: Starts the VM automatically on host boot.

### 1.3 Allocate Storage for EFI and Boot Disks

Allocate storage for the EFI disk (for UEFI) and the primary boot disk:
> Adjust the boot disk `disk-1` size to suit your needs

```bash
pvesm alloc <STORAGE-ID> <VM-ID> vm-<VM-ID>-disk-0 1M 1>&/dev/null
pvesm alloc <STORAGE-ID> <VM-ID> vm-<VM-ID>-disk-1 8G 1>&/dev/null
```

### 1.4 Configure Additional VM Settings

Apply additional configurations to the VM:

```bash
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

## Step 2: Download and Mount the pfSense ISO

### 2.1 Download the pfSense ISO

1. Navigate to the Proxmox web interface.
2. Select the storage (e.g., `local`) under **Datacenter > Storage > ISO Images**.
3. Click **Download from URL** and paste the following URL:

```
https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz
```

4. Click **Download** to retrieve the compressed ISO file.

**Alternative**: If the URL is unavailable, visit [pfSense Download Mirrors](https://atxfiles.netgate.com/mirror/downloads/) to find the latest ISO.

![image](https://github.com/user-attachments/assets/32b00046-a7dc-4a58-8c99-87bc12b1df1c)
![image](https://github.com/user-attachments/assets/02515cef-551f-4db1-8669-89bb4f3d6711)

### 2.2 Mount the ISO to the VM

1. In the Proxmox web interface, select the VM (`<VM-ID>`).
2. Go to **Hardware** > **Add** > **CD/DVD Drive**.
3. Select the downloaded ISO (`pfSense-CE-2.7.2-RELEASE-amd64.iso.gz`).
4. Click **Add** to mount the ISO.

![image](https://github.com/user-attachments/assets/fdb3de0c-8046-44cf-8bcb-65958232f287)

---

## Step 3: Start the VM and Disable Secure Boot

1. Start the VM from the Proxmox web interface.
2. Open the VM console.
3. During the boot splash screen, press **Esc** to enter the UEFI menu.
4. Navigate to **Device Manager** > **Secure Boot Configuration**.
5. Uncheck **Attempt Secure Boot**.
6. Press **F10** to save changes.
7. Press **Esc** to exit the menu.
8. Reset the VM to apply the changes.

**Note**: Disabling Secure Boot is necessary for pfSense to boot correctly with the UEFI configuration.

---

## Step 4: Initial pfSense Configuration

### 4.1 Complete the Setup Wizard

1. On the first boot, pfSense will prompt you to configure the **WAN** and **LAN** interfaces via the CLI:
   - Assign `vtnet0` to WAN (connected to `vmbr0`).
   - Assign `vtnet1` to LAN (connected to `vmbr1`).
2. Follow the CLI prompts to complete the interface setup.
3. Access the pfSense web GUI by navigating to the LAN IP address (default: `192.168.1.1`) in a browser.
4. Run the Setup Wizard to configure basic settings (e.g., hostname, DNS, timezone).

**Temporary GUI Access via WAN** (if needed):
To allow GUI access through the WAN interface temporarily, run the following command in the pfSense console:

```bash
pfctl -d
```

**Warning**: Re-enable the firewall after configuration to secure the WAN interface:

```bash
pfctl -e
```

### 4.2 Enable Serial Console in pfSense

To enable serial console access (useful for Proxmox's xterm.js):

1. In the pfSense web GUI, navigate to **System > Advanced > Admin Access**.
2. Under **Console Options**, select **Enable Serial Console**.
3. Click **Save** and **Apply Changes**.

![image](https://github.com/user-attachments/assets/da3bff1f-1605-4730-bdf5-b66212a78c0f)

### 4.3 Disable Hardware Offloading

Hardware checksum offloading can cause issues with virtualized networking. Disable it as follows:

1. In the pfSense web GUI, go to **System > Advanced > Networking**.
2. Locate the **Networking Interfaces** section.
3. Check **Disable hardware checksum offload**.
4. Click **Save** and **Apply Changes**.
5. Reboot the firewall:
   - Navigate to **Diagnostics > Reboot** or use the console menu.

![image](https://github.com/user-attachments/assets/47fd458d-b373-472a-b391-70916ea7dc7e)

---

## Step 5: Verify and Test

1. **Verify Networking**:
   - Ensure WAN and LAN interfaces are operational.
   - Test internet connectivity from the LAN side.
2. **Check Proxmox Console**:
   - Use the serial console (xterm.js) and make sure you can copy/paste
3. **Backup Configuration**:
   - In the pfSense GUI, go to **Diagnostics > Backup & Restore** and save the configuration.

---

## Troubleshooting

- **VM Fails to Boot**: Verify the ISO is correctly mounted and Secure Boot is disabled.
- **Network Issues**: Ensure `vmbr0` and `vmbr1` are correctly configured in Proxmox.
- **GUI Inaccessible**: Temporarily disable the firewall (`pfctl -d`) and check interface assignments.
- **Performance Issues**: Increase CPU cores or memory if the VM is sluggish.

---

## Additional Notes

- **pfSense Version**: This guide uses pfSense CE 2.7.2. Check for newer versions on the [pfSense website](https://atxfiles.netgate.com/mirror/downloads/).
- **Security**: After setup, ensure the WAN interface is secured and GUI access is restricted.
- **Proxmox Updates**: Keep Proxmox updated to avoid compatibility issues.

