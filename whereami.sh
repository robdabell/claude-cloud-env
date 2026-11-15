#!/usr/bin/env bash
# whereami.sh - a tiny tour of the cloud environment this script runs in.
# Run it in a Claude Code cloud session (or anywhere) to see what the
# container looks like: machine, tools, network policy and repo state.

set -u

section() { printf '\n== %s ==\n' "$1"; }

section "Machine"
echo "Hostname : $(hostname)"
echo "OS       : $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || uname -s)"
echo "Kernel   : $(uname -r)"
echo "CPUs     : $(nproc)"
echo "Memory   : $(free -h 2>/dev/null | awk '/Mem:/ {print $2}')"
echo "Uptime   : $(uptime -p 2>/dev/null || uptime)"
if [ -n "${HTTPS_PROXY:-}" ] || [ -d /root/.ccr ]; then
  echo "Type     : Claude Code cloud container (ephemeral - commit & push to keep work)"
else
  echo "Type     : not a Claude Code cloud container (probably your own machine)"
fi

section "Pre-installed tools"
for tool in git node python3 go rustc java docker gh gcloud; do
  if command -v "$tool" >/dev/null 2>&1; then
    case "$tool" in
      go)   ver=$(go version 2>&1) ;;
      java) ver=$(java -version 2>&1 | grep -v '^Picked up' | head -n1) ;;
      *)    ver=$("$tool" --version 2>&1 | head -n1) ;;
    esac
    printf '  %-8s %s\n' "$tool" "$ver"
  else
    printf '  %-8s (not installed)\n' "$tool"
  fi
done

section "Network policy"
if [ -n "${HTTPS_PROXY:-}" ]; then
  echo "Outbound HTTPS goes through the environment's proxy, which enforces the allowlist."
else
  echo "No HTTPS proxy set: network is not filtered by a cloud environment."
fi
for host in https://registry.npmjs.org https://pypi.org https://example.com; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 "$host" 2>/dev/null)
  if [ "$code" = "000" ] || [ "$code" = "403" ]; then
    printf '  %-28s blocked or unreachable (%s)\n' "$host" "$code"
  else
    printf '  %-28s reachable (HTTP %s)\n' "$host" "$code"
  fi
done

section "Repository"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Repo   : $(basename "$(git rev-parse --show-toplevel)")"
  echo "Branch : $(git branch --show-current)"
  echo "Commit : $(git log -1 --format='%h %s')"
else
  echo "Not inside a git repository."
fi

section "Disk (per-session allowance)"
df -h . | tail -n1 | awk '{print "  Used " $3 " of " $2 " (" $5 ")"}'

echo
echo "Done. Change the environment's network policy, env vars or setup script"
echo "in Claude Code settings, start a new session, and run this again to compare."
