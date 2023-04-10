#!/usr/bin/env bash

# https://stackoverflow.com/a/72476702/1495086

set -x
set -u
set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t13 &>/dev/null; then
    lxc rm --force t13
fi
EOF
chmod +x teardown.sh
./teardown.sh

cat >/tmp/my-user-data-t13 <<'EOF'
#cloud-config
cloud_final_modules:
- rightscale_userdata
- scripts-per-once
- scripts-per-boot
- scripts-per-instance
- scripts-user
- keys-to-console
- phone-home
- final-message

write_files:
- content: |
    #!/bin/bash
    echo "Hello World.  The time is now $(date -R)!" >/var/tmp/hello-world2.txt
  path: /var/lib/cloud/scripts/per-boot/myScript.sh
  permissions: "0755"

runcmd:
- echo 'Hello, World!' >>/var/tmp/hello-world1.txt
EOF

lxc init ubuntu:focal t13 --config=user.user-data="$(cat /tmp/my-user-data-t13)"

for count in {1..2}; do
    echo boot count $count

    lxc start t13
    lxc shell t13 -- bash -c 'cloud-init status --wait'
    lxc shell t13 -- bash -c 'cat /var/tmp/hello-world1.txt'
    lxc shell t13 -- bash -c 'cat /var/tmp/hello-world2.txt'
    lxc stop t13
done
