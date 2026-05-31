#!/usr/bin/env bash
# Seed 2-week demo agenda (1 Jun – 14 Jun 2026) for Me Mori video demo.
# Recording day: 31 May 2026; data starts "besok" and spans two work
# weeks, with a recurring weekly sync every Senin.
#
# Usage:
#   JWT=eyJhbG... ./scripts/seed_agenda.sh
# Optional:
#   BASE_URL=http://localhost:8080 JWT=... ./scripts/seed_agenda.sh
#
# Requires: curl, jq.

set -euo pipefail

BASE_URL="${BASE_URL:-https://mori-backend-993515468883.asia-southeast1.run.app}"
: "${JWT:?Set JWT env var (Bearer token from a logged-in session)}"

seed () {
  curl -sS -X POST "$BASE_URL/api/agenda" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "$1" | jq -r '.id // .error'
}

# ev DATE START END TITLE
ev () {
  local date="$1" start="$2" end="$3" title="$4"
  seed "{\"title\":\"${title}\",\"start_time\":\"${date}T${start}:00+07:00\",\"end_time\":\"${date}T${end}:00+07:00\"}"
}

echo "──────── Recurring (every Senin) ────────"
ev 2026-06-01 10:00 11:00 "Weekly team sync"
ev 2026-06-08 10:00 11:00 "Weekly team sync"

echo "──────── Daily standup (Sen-Jum, 2 minggu) ────────"
for day in 2026-06-01 2026-06-02 2026-06-03 2026-06-04 2026-06-05 \
           2026-06-08 2026-06-09 2026-06-10 2026-06-11 2026-06-12; do
  ev "$day" 09:30 10:00 "Daily standup"
done

echo "──────── Week 1 (1–5 Juni) ────────"
ev 2026-06-01 14:00 15:30 "Sprint planning"
ev 2026-06-02 10:00 12:00 "Deep work — feature flag refactor"
ev 2026-06-02 15:00 16:00 "Code review session"
ev 2026-06-03 11:00 11:30 "1-on-1 dengan tech lead"
ev 2026-06-03 14:00 16:00 "Pair programming dengan junior"
ev 2026-06-04 10:00 12:00 "Deep work — Auth refactor"
ev 2026-06-04 16:00 17:00 "Demo internal"
ev 2026-06-05 10:00 12:00 "Deep work — Release prep"

echo "──────── Collision anchor (Jumat 5 Juni sore) ────────"
ev 2026-06-05 16:00 17:00 "Sync produk"

echo "──────── Week 2 (8–12 Juni) ────────"
ev 2026-06-08 14:00 15:00 "Retrospective sprint"
ev 2026-06-09 10:00 12:00 "Deep work — Onboarding polish"
ev 2026-06-09 15:00 16:00 "Architecture review"
ev 2026-06-10 14:00 15:00 "Vendor call — analytics tool"
ev 2026-06-11 13:00 13:30 "Coffee chat dengan desainer"
ev 2026-06-12 10:00 12:00 "Deep work — Q2 OKR draft"

echo
echo "✅ Done. 26 agendas seeded (1–14 Juni 2026)."
echo "   Today's (31 May) home view tetap kosong — biar Welcome → onboarding"
echo "   flow demo terlihat. Tab 'Minggu ini' & 'Pilih tanggal' yang penuh."
