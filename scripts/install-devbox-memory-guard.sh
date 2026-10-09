#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  printf 'This installer is only for the Linux devbox.\n' >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
user_slice="user-$(id -u).slice"
readonly repo_root user_slice
readonly user_unit="$repo_root/configs/systemd/user/codex-workloads.slice"
readonly system_dropin="$repo_root/configs/systemd/system/user-memory-guard.conf"
readonly wrapper="$repo_root/scripts/rtk-workload-wrapper.sh"

if [[ "$(stat -fc %T /sys/fs/cgroup)" != "cgroup2fs" ]]; then
  printf 'cgroup v2 is required.\n' >&2
  exit 1
fi

if [[ ! -x "$HOME/.local/bin/rtk" ]]; then
  printf 'RTK must be installed at ~/.local/bin/rtk.\n' >&2
  exit 1
fi

systemd-analyze --user verify "$user_unit"
install -D -m 0644 "$user_unit" "$HOME/.config/systemd/user/codex-workloads.slice"
install -D -m 0755 "$wrapper" "$HOME/.local/libexec/codex-workload/bin/rtk"
sudo install -D -m 0644 \
  "$system_dropin" \
  "/etc/systemd/system/$user_slice.d/50-memory-guard.conf"

systemctl --user daemon-reload
systemctl --user start codex-workloads.slice
systemctl --user set-property --runtime codex-workloads.slice MemorySwapMax=7G

sudo systemctl daemon-reload
sudo systemctl set-property --runtime \
  "$user_slice" \
  MemoryAccounting=yes \
  MemoryHigh=93% \
  MemoryMax=95% \
  MemorySwapMax=7680M

printf 'Devbox memory guard installed. Start a new shell to activate the RTK shim.\n'
