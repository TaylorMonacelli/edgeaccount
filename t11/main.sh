#!/usr/bin/env bash

# https://stackoverflow.com/a/72476702/1495086

set -x
set -u
set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t11 &>/dev/null; then
    lxc rm --force t11
fi
EOF
chmod +x teardown.sh
./teardown.sh

cat >/tmp/my-user-data-t11 <<EOF
#cloud-config
runcmd:
- echo 'Hello, World!' >>/root/mytest.txt
EOF

lxc init ubuntu:focal t11 --config=user.user-data="$(cat /tmp/my-user-data-t11)"

grep scripts-user /var/snap/lxd/common/lxd/storage-pools/default/containers/t11/rootfs/etc/cloud/cloud.cfg
# perl -pi -e 's{- scripts-user}{- [scripts-user, always]}' /var/snap/lxd/common/lxd/storage-pools/default/containers/t11/rootfs/etc/cloud/cloud.cfg
grep scripts-user /var/snap/lxd/common/lxd/storage-pools/default/containers/t11/rootfs/etc/cloud/cloud.cfg

echo boot count 1

lxc start t11
lxc shell t11 -- bash -c 'cloud-init status --wait'
lxc shell t11 -- bash -c 'cat /root/mytest.txt'
lxc stop t11

echo boot count 2

lxc start t11
lxc shell t11 -- bash -c 'cloud-init status --wait'
lxc shell t11 -- bash -c 'cat /root/mytest.txt'
lxc stop t11

echo boot count 3

lxc start t11
lxc shell t11 -- bash -c 'cloud-init status --wait'
lxc shell t11 -- bash -c 'cat /root/mytest.txt'
lxc stop t11
