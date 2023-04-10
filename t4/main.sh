#!/usr/bin/env bash

set -x
set -u
# set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t4 &>/dev/null; then
    lxc rm --force t4
fi
EOF
chmod +x teardown.sh
./teardown.sh

cat >/tmp/my-user-data-t4 <<EOF
#cloud-config
runcmd:
- echo 'Hello, World!' >>/root/mytest.txt
EOF

lxc init ubuntu:focal t4 --config=user.user-data="$(cat /tmp/my-user-data-t4)"

lxc start t4
lxc shell t4 -- bash -c 'cloud-init status --wait'
lxc shell t4 -- bash -c 'cat /root/mytest.txt'
lxc shell t4 -- bash -c 'cloud-init single --name scripts-user --frequency always'

cat /var/snap/lxd/common/lxd/storage-pools/default/containers/t4/rootfs/etc/cloud/cloud.cfg
