#!/bin/sh

# Install qemu-guest-agent
pkg install -y qemu-guest-agent

# Configure rc.conf.local
cat > /etc/rc.conf.local <<EOF
qemu_guest_agent_enable="YES"
qemu_guest_agent_flags="-d -v -l /var/log/qemu-ga.log"
#virtio_console_load="YES"
EOF

# Create a startup script with a delay
cat > /usr/local/etc/rc.d/qemu-agent.sh <<EOF
#!/bin/sh
sleep 5
service qemu-guest-agent start
EOF

# Make the script executable
chmod +x /usr/local/etc/rc.d/qemu-agent.sh

# Start the service now
service qemu-guest-agent start
