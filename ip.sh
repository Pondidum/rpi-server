#!/bin/sh

vagrant ssh-config | sed -n 's/.*HostName \(.*\)/\1/p'
