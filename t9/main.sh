#!/usr/bin/env bash

# https://stackoverflow.com/a/72476702/1495086

set -x
set -u
set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t9 &>/dev/null; then
    lxc rm --force t9
fi
EOF
chmod +x teardown.sh
./teardown.sh

lxc init ubuntu:focal t9

cat >>/var/snap/lxd/common/lxd/storage-pools/default/containers/t9/rootfs/etc/cloud/cloud.cfg <<'EOF'
write_files:
- content: |
    #!/bin/bash
    echo "Hello World.  The time is now $(date -R)!" >>/var/tmp/hello-world.txt
  path: /var/lib/cloud/scripts/per-boot/myScript.sh
  permissions: "0755"
EOF

for count in {1..2}; do
    echo boot count $count

    lxc start t9
    lxc shell t9 -- bash -c 'cloud-init status --wait'
    lxc shell t9 -- bash -c 'cat /var/tmp/hello-world.txt'
    lxc stop t9
done
