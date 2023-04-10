#!/usr/bin/env bash

set -x
set -u
# set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t2 &>/dev/null; then
    lxc rm --force t2
fi
EOF
chmod +x teardown.sh
./teardown.sh

cat >/tmp/my-user-data-t2 <<EOF
#cloud-config
runcmd:
- echo 'Hello, World!' >>/root/mytest.txt
EOF

lxc init ubuntu:focal t2 --config=user.user-data="$(cat /tmp/my-user-data-t2)"

lxc start t2
lxc shell t2 -- bash -c 'cloud-init status --wait'
lxc shell t2 -- bash -c 'cat /root/mytest.txt'
lxc stop t2

lxc start t2
lxc shell t2 -- bash -c 'cloud-init status --wait'
lxc shell t2 -- bash -c 'cat /root/mytest.txt'
