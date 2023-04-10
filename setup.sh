#!/usr/bin/env bash

apt-get -qq update </dev/null

apt-get -qy install lxc </dev/null

lxd init --auto
