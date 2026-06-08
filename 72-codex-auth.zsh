# Codex auth slot helpers.
#
# These swap only ~/.codex/auth.json so the same Codex config, plugins,
# history, skills, and project trust state continue to be used.

export CODEX_AUTH_SLOTS_DIR="${CODEX_AUTH_SLOTS_DIR:-$HOME/.codex/auth-slots}"
export CODEX_APP_SERVER_SOCK="${CODEX_APP_SERVER_SOCK:-$HOME/.codex/app-server-control/desktop-ssh-websocket-v0.sock}"

_codex_auth_init() {
  mkdir -p "$HOME/.codex" "$CODEX_AUTH_SLOTS_DIR" || return
  chmod 700 "$HOME/.codex" "$CODEX_AUTH_SLOTS_DIR" 2>/dev/null || true
}

_codex_auth_slot_path() {
  local slot="${1:-}"
  if [[ -z "$slot" ]]; then
    print -u2 "usage: <command> <slot>"
    return 2
  fi
  if [[ ! "$slot" =~ '^[A-Za-z0-9][A-Za-z0-9._-]*$' ]]; then
    print -u2 "Invalid slot name: $slot"
    print -u2 "Use letters, numbers, dots, underscores, and hyphens; start with a letter or number."
    return 2
  fi
  print -r -- "$CODEX_AUTH_SLOTS_DIR/$slot.json"
}

_codex_auth_base64_decode() {
  if printf '' | base64 -D >/dev/null 2>&1; then
    base64 -D
  else
    base64 -d
  fi
}

_codex_auth_email_for_file() {
  local file="${1:-}"
  local token payload decoded identity account

  if [[ ! -r "$file" ]] || ! command -v jq >/dev/null 2>&1; then
    print "unknown-email"
    return 0
  fi

  token="$(jq -r '.tokens.id_token // .id_token // empty' "$file" 2>/dev/null)" || token=""
  if [[ -n "$token" && "$token" == *.*.* ]]; then
    payload="${token#*.}"
    payload="${payload%%.*}"
    payload="$(printf '%s' "$payload" | tr '_-' '/+')"
    while (( ${#payload} % 4 )); do
      payload="${payload}="
    done
    decoded="$(printf '%s' "$payload" | _codex_auth_base64_decode 2>/dev/null)" || decoded=""
    identity="$(printf '%s' "$decoded" | jq -r '.email // .preferred_username // .upn // .name // empty' 2>/dev/null)" || identity=""
  fi

  if [[ -z "$identity" || "$identity" == "null" ]]; then
    account="$(jq -r '.tokens.account_id // .account_id // empty' "$file" 2>/dev/null)" || account=""
    if [[ -n "$account" && "$account" != "null" ]]; then
      identity="account:$account"
    else
      identity="unknown-email"
    fi
  fi

  print -r -- "$identity"
}

_codex_auth_file_mtime() {
  local file="${1:-}"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$file" 2>/dev/null
  else
    stat -c '%y' "$file" 2>/dev/null | cut -d. -f1
  fi
}

_codex_app_server_pids() {
  local sock="${1:-$CODEX_APP_SERVER_SOCK}"
  ps -eo pid=,args= | awk -v sock="$sock" '
    index($0, "awk -v sock=") { next }
    index($0, "codex app-server --listen unix://") && index($0, sock) { print $1 }
    index($0, "codex app-server proxy --sock") && index($0, sock) { print $1 }
  '
}

_codex_app_server_processes() {
  local sock="${1:-$CODEX_APP_SERVER_SOCK}"
  ps -eo pid=,lstart=,args= | awk -v sock="$sock" '
    index($0, "awk -v sock=") { next }
    index($0, "codex app-server --listen unix://") && index($0, sock) { print }
    index($0, "codex app-server proxy --sock") && index($0, sock) { print }
  '
}

codex-app-server-status() {
  local sock="${1:-$CODEX_APP_SERVER_SOCK}"
  print "Active Codex login: $(codex-auth-current 2>/dev/null)"
  print "Socket: $sock"
  if [[ -S "$sock" ]]; then
    print "Socket status: ready"
  else
    print "Socket status: missing"
  fi
  print "Processes:"
  _codex_app_server_processes "$sock"
}

codex-app-server-stop() {
  local sock="${1:-$CODEX_APP_SERVER_SOCK}"
  local pids
  pids="$(_codex_app_server_pids "$sock" | tr '\n' ' ')"
  if [[ -n "${pids// /}" ]]; then
    print "Stopping Codex app-server for: $sock"
    kill ${(z)pids} 2>/dev/null || true
    sleep 2
    pids="$(_codex_app_server_pids "$sock" | tr '\n' ' ')"
    [[ -n "${pids// /}" ]] && kill -KILL ${(z)pids} 2>/dev/null || true
  else
    print "No Codex app-server process found for: $sock"
  fi
  rm -f "$sock"
}

codex-app-server-restart() {
  local sock="${1:-$CODEX_APP_SERVER_SOCK}"
  local pidfile="$HOME/.codex/app-server-control/app-server.pid"
  local logfile="$HOME/.codex/app-server-control/app-server.log"
  if ! command -v codex >/dev/null 2>&1; then
    print -u2 "codex command not found on PATH"
    return 127
  fi
  codex-app-server-stop "$sock" >/dev/null
  mkdir -p "${sock:h}" "$HOME/.codex/app-server-control" || return
  chmod 700 "$HOME/.codex" "$HOME/.codex/app-server-control" 2>/dev/null || true
  print "Starting Codex app-server for: $sock"
  nohup codex app-server --listen "unix://$sock" >> "$logfile" 2>&1 &
  print "$!" > "$pidfile"
  sleep 3
  if [[ ! -S "$sock" ]]; then
    print -u2 "Codex app-server did not create socket: $sock"
    return 1
  fi
  print "Codex app-server restarted under: $(codex-auth-current 2>/dev/null)"
}

codex-auth-save() {
  local slot="${1:-}"
  local target email
  target="$(_codex_auth_slot_path "$slot")" || return
  _codex_auth_init || return
  if [[ ! -f "$HOME/.codex/auth.json" ]]; then
    print -u2 "No active Codex auth found at ~/.codex/auth.json"
    return 1
  fi
  cp "$HOME/.codex/auth.json" "$target" || return
  chmod 600 "$target"
  email="$(_codex_auth_email_for_file "$target")"
  print "Saved active Codex login as: $slot ($email)"
}

codex-auth-use() {
  local restart_app_server=0
  if [[ "${1:-}" == "--restart-app-server" ]]; then
    restart_app_server=1
    shift
  fi
  local slot="${1:-}"
  local source email
  source="$(_codex_auth_slot_path "$slot")" || return
  _codex_auth_init || return
  if [[ ! -f "$source" ]]; then
    print -u2 "No Codex auth slot named: $slot"
    return 1
  fi
  cp "$source" "$HOME/.codex/auth.json" || return
  chmod 600 "$HOME/.codex/auth.json"
  email="$(_codex_auth_email_for_file "$source")"
  print "Switched active Codex login to: $slot ($email)"
  if (( restart_app_server )); then
    codex-app-server-restart
  fi
}

codex-auth-current() {
  local slot_only=0
  local active="$HOME/.codex/auth.json"
  local f slot email

  [[ "${1:-}" == "--slot-only" ]] && slot_only=1
  _codex_auth_init || return

  if [[ ! -f "$active" ]]; then
    print "none"
    return 1
  fi

  for f in "$CODEX_AUTH_SLOTS_DIR"/*.json(N); do
    if cmp -s "$active" "$f"; then
      slot="$(basename "$f" .json)"
      if (( slot_only )); then
        print "$slot"
      else
        email="$(_codex_auth_email_for_file "$active")"
        print "$slot  $email"
      fi
      return 0
    fi
  done

  if (( slot_only )); then
    print "unsaved-active-login"
  else
    email="$(_codex_auth_email_for_file "$active")"
    print "unsaved-active-login  $email"
  fi
}

codex-auth-list() {
  _codex_auth_init || return
  local active="$HOME/.codex/auth.json"
  local f slot marker stamp email
  if [[ -z "$(print -r -- "$CODEX_AUTH_SLOTS_DIR"/*.json(N))" ]]; then
    print "No Codex auth slots saved in $CODEX_AUTH_SLOTS_DIR"
    return 0
  fi
  printf '%s %-24s %-40s %s\n' " " "slot" "email" "saved_at"
  for f in "$CODEX_AUTH_SLOTS_DIR"/*.json(N); do
    slot="$(basename "$f" .json)"
    marker=" "
    [[ -f "$active" ]] && cmp -s "$active" "$f" && marker="*"
    stamp="$(_codex_auth_file_mtime "$f")"
    email="$(_codex_auth_email_for_file "$f")"
    printf '%s %-24s %-40s %s\n' "$marker" "$slot" "$email" "$stamp"
  done
}

codex-auth-login() {
  local slot="${1:-}"
  local target tmp_root tmp_home email status
  target="$(_codex_auth_slot_path "$slot")" || return
  shift
  _codex_auth_init || return

  tmp_root="${TMPDIR:-/tmp}"
  tmp_home="$(mktemp -d "${tmp_root%/}/codex-auth-login.XXXXXX")" || return
  chmod 700 "$tmp_home"
  trap '[[ -n "$tmp_home" && -d "$tmp_home" ]] && rm -rf "$tmp_home"' EXIT INT TERM HUP

  print "Starting Codex login for slot: $slot"
  print "This changes only ~/.codex/auth.json after login succeeds. Existing config/plugins/history stay in ~/.codex."
  CODEX_HOME="$tmp_home" codex login -c 'cli_auth_credentials_store="file"' "$@"
  status=$?
  if (( status != 0 )); then
    print -u2 "Codex login failed; active login was not changed."
    rm -rf "$tmp_home"
    trap - EXIT INT TERM HUP
    return "$status"
  fi

  if [[ ! -f "$tmp_home/auth.json" ]]; then
    print -u2 "Codex login completed but temporary auth.json was not created."
    rm -rf "$tmp_home"
    trap - EXIT INT TERM HUP
    return 1
  fi

  cp "$tmp_home/auth.json" "$target" || return
  chmod 600 "$target"
  cp "$target" "$HOME/.codex/auth.json" || return
  chmod 600 "$HOME/.codex/auth.json"
  email="$(_codex_auth_email_for_file "$target")"
  rm -rf "$tmp_home"
  trap - EXIT INT TERM HUP
  print "Saved and activated Codex login slot: $slot ($email)"
}

codex-auth-status() {
  print "Active slot: $(codex-auth-current 2>/dev/null)"
  codex login status "$@"
}
