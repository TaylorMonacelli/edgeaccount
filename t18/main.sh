#!/usr/bin/env bash

set -x
set -u
set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t18 &>/dev/null; then
    lxc rm --force t18
fi
EOF
chmod +x teardown.sh
./teardown.sh

cat >/tmp/my-user-data-t18 <<'EOF'
#cloud-config
cloud_final_modules:
# - scripts-per-once
# - scripts-per-boot
# - scripts-per-instance
- scripts-user

runcmd:
- echo 'Hello, World!' >>/var/tmp/hello-runcmd.txt

write_files:
- content: |
    #!/bin/bash
    echo "Hello World.  The time is now $(date -R)!" >>/var/tmp/hello-per-boot.txt
  path: /var/lib/cloud/scripts/per-boot/myscript-per-boot1.sh
  permissions: "0755"
- content: |
    #!/bin/bash
    echo "Hello World.  The time is now $(date -R)!" >>/var/tmp/hello-per-once.txt
  path: /var/lib/cloud/scripts/per-once/myscript-per-once1.sh
  permissions: "0755"
EOF

lxc init ubuntu:focal t18 --config=user.user-data="$(cat /tmp/my-user-data-t18)"

for count in {1..3}; do
    echo boot count $count

    lxc start t18
    lxc shell t18 -- bash -c 'cloud-init status --wait'
    lxc shell t18 -- bash -c 'cat /var/tmp/hello-runcmd.txt'
    lxc shell t18 -- bash -c 'cat /var/tmp/hello-per-boot.txt'
    lxc shell t18 -- bash -c 'cat /var/tmp/hello-per-once.txt'
    lxc stop t18
done
