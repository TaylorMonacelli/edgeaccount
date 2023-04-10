#!/usr/bin/env bash

# https://stackoverflow.com/a/10455027/1495086
# https://stackoverflow.com/a/72476702/1495086

set -x
set -u
set -e

cat >teardown.sh <<'EOF'
#!/usr/bin/env bash

set -x
set -u

if lxc info t12 &>/dev/null; then
    lxc rm --force t12
fi
EOF
chmod +x teardown.sh
./teardown.sh

cat >/tmp/my-user-data-t12 <<EOF
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

runcmd:
- echo 'Hello, World!' >>/var/tmp/hello-world.txt
EOF

lxc init ubuntu:focal t12 --config=user.user-data="$(cat /tmp/my-user-data-t12)"

grep scripts-user /var/snap/lxd/common/lxd/storage-pools/default/containers/t12/rootfs/etc/cloud/cloud.cfg

for count in {1..3}; do
    echo boot count $count

    lxc start t12
    lxc shell t12 -- bash -c 'cloud-init status --wait'
    lxc shell t12 -- bash -c 'cat /var/tmp/hello-world.txt'
    lxc stop t12
done
