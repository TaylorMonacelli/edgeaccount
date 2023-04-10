#!/usr/bin/env bash

# https://stackoverflow.com/a/72476702/1495086

set -x
set -u
set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t14 &>/dev/null; then
    lxc rm --force t14
fi
EOF
chmod +x teardown.sh
./teardown.sh

cat >/tmp/my-user-data-t14 <<'EOF'
#cloud-config
cloud_final_modules:
- rightscale_userdata
- scripts-per-once
- scripts-per-boot
- scripts-per-instance
- [scripts-user, always]
- keys-to-console
- phone-home
- final-message

write_files:
- content: |
    #!/bin/bash
    echo "Hello World.  The time is now $(date -R)!" >/var/tmp/hello-per-boot.txt
  path: /var/lib/cloud/scripts/per-boot/myscript-per-boot1.sh
  permissions: "0755"

runcmd:
- echo 'Hello, World!' >>/var/tmp/hello-runcmd.txt
EOF

lxc init ubuntu:focal t14 --config=user.user-data="$(cat /tmp/my-user-data-t14)"

for count in {1..3}; do
    echo boot count $count

    lxc start t14
    lxc shell t14 -- bash -c 'cloud-init status --wait'
    lxc shell t14 -- bash -c 'cat /var/tmp/hello-runcmd.txt'
    lxc shell t14 -- bash -c 'cat /var/tmp/hello-per-boot.txt'
    lxc stop t14
done
