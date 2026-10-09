#!/usr/bin/env bash
set -u

readonly real_rtk="$HOME/.local/bin/rtk"
readonly workload_slice="codex-workloads.slice"

if [[ ! -x "$real_rtk" ]]; then
  printf 'rtk workload wrapper: executable not found: %s\n' "$real_rtk" >&2
  exit 127
fi

# Nested RTK calls stay in the command's existing workload scope.
if grep -q '/codex-workloads\.slice/' /proc/self/cgroup 2>/dev/null; then
  exec "$real_rtk" "$@"
fi

if [[ -n "${XDG_RUNTIME_DIR:-}" ]] && command -v systemd-run >/dev/null 2>&1; then
  exec systemd-run \
    --user \
    --scope \
    --quiet \
    --collect \
    --slice="$workload_slice" \
    --property=MemoryAccounting=yes \
    --property=OOMPolicy=kill \
    -- "$real_rtk" "$@"
fi

printf 'rtk workload wrapper: user systemd unavailable; running without a workload scope\n' >&2
exec "$real_rtk" "$@"
