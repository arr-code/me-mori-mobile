# Me Mori — Video Demo Script

Rekaman: **31 Mei 2026 (Minggu malam)**.
Dummy agenda: **1 – 14 Juni 2026** (2 minggu kerja, plus recurring Senin).

---

## 0 · Persiapan

### Akun demo
- **Username**: `noia_demo`
- **Nama (display)**: `Noia`
- **Persona**: Software Engineer di startup tech

### Backend warm-up
- Buka `BASE_URL/healthz` 1 menit sebelum rekam (hindari Cloud Run cold
  start ≈3 detik).
- WiFi stabil, HP & Mac sama jaringan.

### Pre-seed agenda dummy

Ambil JWT dari log app (tambah `debugPrint('JWT: ${res.token}')` sementara
di [auth_controller.dart](lib/features/auth/application/auth_controller.dart)
setelah `state = Authenticated(...)`), lalu:

```bash
JWT=eyJhbG... ./scripts/seed_agenda.sh
```

Hasil seed:

| Hari | Agenda |
|---|---|
| **Tiap Senin (1 & 8 Jun)** | `Weekly team sync` 10.00–11.00 — recurring |
| **Sen–Jum (10 hari)** | `Daily standup` 09.30–10.00 |
| Sen 1 Jun | Sprint planning 14.00–15.30 |
| Sel 2 Jun | Deep work 10.00–12.00, Code review 15.00–16.00 |
| Rab 3 Jun | 1-on-1 tech lead 11.00, Pair programming 14.00–16.00 |
| Kam 4 Jun | Deep work 10.00–12.00, Demo internal 16.00 |
| Jum 5 Jun | Deep work 10.00–12.00, **Sync produk 16.00–17.00** ← collision anchor |
| Sen 8 Jun | Retrospective 14.00 |
| Sel 9 Jun | Deep work 10.00–12.00, Architecture review 15.00 |
| Rab 10 Jun | Vendor call 14.00 |
| Kam 11 Jun | Coffee chat 13.00 |
| Jum 12 Jun | Deep work 10.00–12.00 |

Total: **26 agenda**. Hari ini (31 Mei) tetap kosong — sengaja, supaya
flow Welcome → empty home → "Mulai ngobrol" CTA bisa di-demo. Tab
"Minggu ini" yang akan penuh.

### Setup visual
- System theme: **Dark** (splash + welcome lebih dramatis)
- Brightness HP 80%+
- HP silent / DND, sembunyikan notifikasi

---

## 1 · Onboarding profile (paste content)

Persona dipilih karena pola kerjanya detail → Mori bisa reference
"deep work" / "standup" saat saran, dan aturan pribadi mudah trigger
collision card.

| Field | Isi |
|---|---|
| **Profesi** | `Software Engineer` |
| **Tujuan kamu** | `Ship 2 fitur besar bulan ini. Code review tim selesai dalam 24 jam. Punya 3 jam deep work per hari.` |
| **Pola kerja** | `Senin-Jumat 09.00-18.00. Daily standup 09.30. Deep work 10.00-12.00. Meeting 14.00-17.00. Sabtu off.` |
| **Aturan pribadi** (opsional) | `Tidak meeting Jumat sore. Tidak ada call setelah 19.00.` |
| **Bio** (opsional) | `Hybrid: WFO Senin-Rabu, WFH Kamis-Jumat. Hobi gym & ngopi sore.` |

---

## 2 · Script chat (urutan pesan saat scene chat)

Sengaja pakai tanggal eksplisit di sebagian besar pesan biar Mori tidak
salah parse ("besok" relatif terhadap server time, kadang berbeda).

| # | Pesan | Yang di-demo | Target |
|---|---|---|---|
| 1 | `halo` | Greeting — non-action turn, no card | — |
| 2 | `rangkumkan jadwal bulan ini` | **Summarize** — intent=`summarize`, Mori baca data → balas ringkasan teks. Tidak ada action card | Tunjukin Mori paham konteks (jumlah meeting, recurring, jeda) |
| 3 | `tambah meeting tim 6 Juni jam 14 sampai 15` | Single **add**, happy path | Sabtu 6 Juni (slot kosong) |
| 4 | `tambah call vendor 5 Juni jam 16` | **Collision** dengan "Sync produk" | Bentrok → card 2-button |
| 5 | `geser sprint planning besok jadi jam 11` | **Update** existing | Sprint planning 1 Jun → 11:00 |
| 6 | `tandai daily standup besok sudah selesai` | **Toggle done** | Standup 1 Jun strikethrough |
| 7 | `hapus demo internal kamis 4 Juni` | **Delete** | Demo internal 4 Jun hilang |

Tap **Setuju** semua kecuali #4 (tap **Batal** biar tunjukin pill
"Dibatalkan"). Pesan #1 & #2 tidak punya card — cuma bubble reply.

---

## 3 · Highlight reel (~75 detik) — pitch / sosmed

Fokus: **chat → agenda**. Asumsi user sudah login.

| Detik | Adegan | Caption overlay |
|---|---|---|
| 0–5 | Cold start: Crest splash (ring + orbit + memento mori) | `Mori — asisten jadwal yang ngerti bahasa kamu` |
| 5–10 | Welcome → tap Mulai → langsung Home (returning user) | |
| 10–18 | Home: tab "Hari ini" (kosong) → swipe ke "Minggu ini" → penuh dengan agenda | `Mori atur jadwal lewat obrolan` |
| 18–22 | Tap FAB "Tulis ke Mori…" → chat | `Tulis pakai bahasa biasa…` |
| 22–32 | Ketik pesan #2 (`rangkumkan jadwal bulan ini`) → Mori balas ringkasan teks | `Mori paham konteks jadwal kamu` |
| 32–42 | Kirim pesan #3 (`tambah meeting tim 6 Juni jam 14-15`) → action card | `Tulis pakai bahasa biasa…` |
| 42–50 | Tap **Setuju** → "✓ Aksi selesai" | `Setuju? Beres.` |
| 50–58 | Kirim pesan #4 (collision) → card warning bentrok dengan Sync produk | `Mori jaga supaya kamu tidak double-book` |
| 58–65 | Back → Home → tab **Pilih tanggal** → date picker → pilih 6 Juni → liat agenda baru | `Cek tanggal apapun` |
| 65–70 | Swipe agenda kiri → tap centang → strikethrough | |
| 70–75 | Tap avatar → Profile → toggle theme Dark→Light | |

---

## 4 · Full walkthrough (~3–4 menit) — dokumentasi / training

Pakai akun baru, mulai dari nol.

```
1.  Splash Crest (5 detik fixed)
2.  Welcome (3 pillars) → tap "Mulai"
3.  SignInSelect → tap "Daftar dengan Email" (atau Google)
4.  Register: username=noia_demo, password, nama=Noia
5.  Nickname prompt → pilih chip "Noia" → Lanjut
6.  Onboarding 5-field: paste dari section 1 → "Selesai onboarding"
7.  Home kosong (hari ini Minggu, no schedule) → tap "Mulai ngobrol"
8.  Chat: pesan #1 (halo)
9.  Chat: pesan #2 (rangkumkan jadwal bulan ini) — tunjukin Mori paham konteks
10. Chat: pesan #3 (tambah meeting 6 Juni) → Setuju
11. Chat: pesan #4 (collision call vendor 5 Juni jam 16) → Batal
12. Back → Home → tab "Minggu ini" → liat agenda existing + yang baru
13. Tap tab "Pilih tanggal" → pilih 1 Juni → liat Weekly sync + Sprint planning + Standup
14. Pilih lagi 8 Juni → liat Retrospective + Standup + Weekly sync
15. Swipe kiri salah satu agenda → toggle done (centang)
16. Swipe kiri lagi → tap delete → konfirmasi
17. Tap avatar → Profile screen
18. Theme toggle 3-way: Terang / Gelap / Otomatis
19. Scroll profil — semua field populated dari onboarding
20. (Kalau via Google) Akun group → pill "Terhubung"
21. Tap "Keluar dari akun" → konfirmasi → balik ke Welcome
```

---

## 5 · Tips rekaman

**Mirror layar HP ke Mac (cara terbersih)**
```bash
brew install scrcpy
scrcpy --max-size 1080 --window-title "Me Mori Demo"
```
Rekam window scrcpy pakai QuickTime (`Cmd+Shift+5`) atau OBS.

**Editing**
- Speed-up 1.5×–2× di scene typing indicator kalau backend lambat.
- Subtle zoom-in saat action card muncul + saat agenda di-tap.
- Backsound: ambient instrumental, no vocals, ~60bpm.
- Caption overlay sesuai tabel highlight reel.

**Yang dihindari**
- Notifikasi push HP (silent mode).
- Status bar nampak personal info — pakai demo mode kalau perlu.
- Mengetik pelan-pelan di composer chat — paste dari clipboard.
- Cold-start backend — warm up dulu via `/healthz`.

---

## 6 · Reset data (kalau perlu rekam ulang)

```bash
# Hapus semua agenda dengan reset chat tidak menghapus agenda.
# Saat ini belum ada bulk delete endpoint — paling cepat hapus user
# di backend lalu register ulang, atau loop DELETE /api/agenda/:id.
#
# Untuk reset chat history (biar transcript di app bersih):
curl -X POST "$BASE_URL/api/chat/reset" -H "Authorization: Bearer $JWT"
```
