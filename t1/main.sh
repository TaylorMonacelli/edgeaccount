#!/usr/bin/env bash

set -x
set -u
# set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t1 &>/dev/null; then
    lxc rm --force t1
fi
EOF
chmod +x teardown.sh
./teardown.sh

cat >/tmp/my-user-data <<EOF
#cloud-config
runcmd:
- echo 'Hello, World!' >>/root/mytest.txt
EOF

lxc init ubuntu:focal t1 --config=user.user-data="$(cat /tmp/my-user-data)"

grep runcmd /var/snap/lxd/common/lxd/storage-pools/default/containers/t1/rootfs/etc/cloud/cloud.cfg

perl -pi -e 's{- runcmd}{- [runcmd, always]}' /var/snap/lxd/common/lxd/storage-pools/default/containers/t1/rootfs/etc/cloud/cloud.cfg
grep runcmd /var/snap/lxd/common/lxd/storage-pools/default/containers/t1/rootfs/etc/cloud/cloud.cfg

lxc start t1
lxc shell t1 -- bash -c 'cloud-init status --wait'
lxc shell t1 -- bash -c 'grep runcmd /etc/cloud/cloud.cfg'
lxc shell t1 -- bash -c 'cat /root/mytest.txt'
lxc stop t1

lxc start t1
lxc shell t1 -- bash -c 'cloud-init status --wait'
lxc shell t1 -- bash -c 'grep runcmd /etc/cloud/cloud.cfg'
lxc shell t1 -- bash -c 'cat /root/mytest.txt'
lxc stop t1
