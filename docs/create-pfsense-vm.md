## Download pfsense ISO

## Create VM:
   Edit the following values and then execute in Proxmox Shell:
   
   `<VM-ID>` - Example: `1000`
   
   `<STORAGE-ID>` - Example: `local-zfs`
   
   `<VM-NAME>` - Example: `pfsense`
### Step 1: Create the VM with basic settings
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

---
### Step 2: Allocate storage for EFI disk and boot disk
```
pvesm alloc <STORAGE-ID> <VM-ID> vm-<VM-ID>-disk-0 1M 1>&/dev/null
pvesm alloc <STORAGE-ID> <VM-ID> vm-<VM-ID>-disk-1 8G 1>&/dev/null
```
---
### Step 3: Set additional VM configurations
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
