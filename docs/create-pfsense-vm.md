## Download pfsense ISO

## Create VM:
   Edit the following values and then execute in Proxmox Shell:
   `<VM-ID>` 
   `<STORAGE-ID>`
   `<VM-NAME>`
   ```
   qm create <VM-ID> \
   --name <VM-NAME> \
   --memory 8192 \
   --cores 2 \
   --sockets 1 \
   --bios ovmf \
   --machine q35 \
   --scsihw virtio-scsi-single \
   --boot order=virtio0 \
   --ostype other \
   --agent enabled=1 \
   --efidisk0 <STORAGE-ID>:vm-<VM-ID>-disk-0,efitype=4m,pre-enrolled-keys=1,size=1M \
   --scsi0 <STORAGE-ID>:vm-<VM-ID>-disk-1,discard=on,iothread=1,size=8G \
   --net0 virtio,bridge=vmbr0 \
   --net1 virtio,bridge=vmbr1 \
   --vga qxl
   ```
