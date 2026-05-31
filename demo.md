# Me Mori — Demo (~7 menit)

**Pre-demo**: deploy fix timeparser + chat.go, smoke test chat sekali, browser Incognito.

## Flow

1. Splash → **Mulai**
2. Welcome → **Daftar dengan Email**
3. Register `noia_demo` / pass / nama Noia
4. Nickname chip **Noia** → Lanjut
5. Onboarding 5-field (paste di bawah) → **Selesai**
6. Home → **Mulai ngobrol**
7. `halo` → Mori sapa pakai nama
8. `agenda hari ini` → jawab ringkas
9. `tambah meeting 6 juni jam 10` → action card → **Setuju**
10. `tambah meeting 5 juni jam 17` → collision → **Batal**
11. Back → Home → tab **Minggu ini**
12. Pilih **1 Juni** & **8 Juni** → agenda existing
13. Swipe agenda → toggle done
14. Swipe lagi → delete → konfirmasi
15. Avatar → Profile
16. Theme: **Terang → Gelap → Otomatis**
17. **Keluar dari akun** → balik Welcome

## Onboarding paste

- **Profesi**: Konsultan strategi
- **Tujuan**: Pegang 3 klien aktif, 1 hari fokus mingguan, olahraga 3×/minggu.
- **Pola kerja**: Senin–Jumat 08–21. Istirahat 12, 15, 18.
- **Aturan**: Tidak ada meeting setelah jam 7 malam.
- **Bio**: Suka teh hangat.

## Fallback

- Msg #9 gagal → ganti `tambah ngopi besok jam 9`
- Collision tidak fire → skip ke step 11
- Chat hang → tap **ulangi**
