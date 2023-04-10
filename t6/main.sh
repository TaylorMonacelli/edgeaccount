#!/usr/bin/env bash

# https://stackoverflow.com/a/72476702/1495086

set -x
set -u
set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t6 &>/dev/null; then
    lxc rm --force t6
fi
EOF
chmod +x teardown.sh
./teardown.sh

lxc init ubuntu:focal t6

cat >>/var/snap/lxd/common/lxd/storage-pools/default/containers/t6/rootfs/etc/cloud/cloud.cfg <<'EOF'
write_files:
- content: |
    #!/bin/bash
    echo "Hello World.  The time is now $(date -R)!" >>/root/mytest.txt
  path: /var/lib/cloud/scripts/per-boot/myScript.sh
  permissions: "0755"
EOF

for count in {1..2}; do
    echo boot count $count

    lxc start t6
    lxc shell t6 -- bash -c 'cloud-init status --wait'
    lxc shell t6 -- bash -c 'cat /root/mytest.txt'
    lxc stop t6
done
