#!/usr/bin/bash
# run step 50 detached and wait for it; prints the tail of the log
cd $HOME/src/pr4
systemd-run --user --unit=sp11-build-iso --collect --working-directory=$HOME/src/pr4 --setenv=SP11_REDISTRIBUTABLE=1 /bin/bash -c 'scripts/50-build-iso.sh > build/step50.log 2>&1; echo "exit=$? finished $(date +%T)" >> build/step50.log' >/dev/null 2>&1
sleep 3; until [ "$(systemctl --user is-active sp11-build-iso)" != active ]; do sleep 10; done
tail -${1:-6} build/step50.log | sed 's/\x1b\[[0-9;]*m//g' | cut -c1-240; ls -la build/out | tail -2; cat /run/sp11-thermal-cap.status
