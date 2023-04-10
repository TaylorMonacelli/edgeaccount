#!/usr/bin/env bash

set -x
set -u
# set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t3 &>/dev/null; then
    lxc rm --force t3
fi
EOF
chmod +x teardown.sh
./teardown.sh

cat >/tmp/my-user-data-t3 <<EOF
#cloud-config
runcmd:
- echo 'Hello, World!' >>/root/mytest.txt
EOF

lxc init ubuntu:focal t3 --config=user.user-data="$(cat /tmp/my-user-data-t3)"

lxc start t3
lxc shell t3 -- bash -c 'cloud-init status --wait'
lxc shell t3 -- bash -c 'cat /root/mytest.txt'

lxc shell t3 -- bash -c 'cloud-init clean --logs'
lxc shell t3 -- bash -c 'cloud-init query userdata'
lxc shell t3 -- bash -c 'cloud-init init --local'
lxc shell t3 -- bash -c 'cloud-init init'
lxc shell t3 -- bash -c 'cloud-init modules --mode=config'
lxc shell t3 -- bash -c 'cloud-init modules --mode=final'

lxc shell t3 -- bash -c 'cat /root/mytest.txt'
