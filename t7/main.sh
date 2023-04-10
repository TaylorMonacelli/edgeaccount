#!/usr/bin/env bash

# https://stackoverflow.com/a/72476702/1495086

set -x
set -u
set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t7 &>/dev/null; then
    lxc rm --force t7
fi
EOF
chmod +x teardown.sh
./teardown.sh

lxc init ubuntu:focal t7

cat >>/var/snap/lxd/common/lxd/storage-pools/default/containers/t7/rootfs/etc/cloud/cloud.cfg <<'EOF'
write_files:
- content: |
    #!/bin/bash
    echo "Hello World.  The time is now $(date -R)!" >>/root/mytest.txt
  path: /var/lib/cloud/scripts/per-boot/myScript.sh
  permissions: "0755"
EOF

for count in {1..2}; do
    echo boot count $count

    lxc start t7
    lxc shell t7 -- bash -c 'cat /root/mytest.txt'
    lxc stop t7
done
