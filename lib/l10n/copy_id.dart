/// Static Indonesian copy. Mori's voice: third-person, settled, ringkas.
/// Phase 0: just enough for buttons + debug; later phases extend per design.
class CopyId {
  const CopyId._();

  // Generic actions
  static const setuju = 'Setuju';
  static const batal = 'Batal';
  static const simpan = 'Simpan';
  static const ganti = 'Ganti';
  static const tetapTambah = 'Tetap tambah';

  // Loading
  static const memuat = 'Memuat...';
  static const mendaftar = 'Mendaftar...';
  static const masuk = 'Masuk...';

  // Auth
  static const daftar = 'Daftar';
  static const login = 'Login';
  static const lanjutGoogle = 'Lanjut dengan Google';

  // Chat
  static String haloGreeting(String name) =>
      'Halo, $name. Ada yang Mori bantu?';
  static const hariKosong = 'Hari kosong. Mau atur sesuatu?';

  // Statuses
  static const aksiSelesai = '✓ Aksi selesai';
  static const dibatalkan = 'Dibatalkan';
  static const diganti = 'Diganti — agenda lama dihapus';

  // Errors
  static const errCreds = 'Username atau password salah.';
  static const errUsernameTaken = 'Username sudah dipakai. Coba yang lain.';
  static const errUsernameInvalid =
      'Username harus 8-30 karakter, hanya huruf, angka, dan underscore.';
  static const errPasswordShort = 'Password minimal 8 karakter.';
  static const errNetwork = 'Koneksi bermasalah. Coba lagi.';

  // Theme labels
  static const themeTerang = 'Terang';
  static const themeGelap = 'Gelap';
  static const themeOtomatis = 'Otomatis';

  // Profile screen
  static const profileTitle = 'Profil & pengaturan';
  static const profileGroupProfil = 'Profil';
  static const profileGroupAkun = 'Akun';
  static const profileGroupPreferensi = 'Preferensi';
  static const profileGroupPrivasi = 'Privasi & data';
  static const profileGroupTentang = 'Tentang';

  static const profileRowProfesi = 'Profesi';
  static const profileRowTujuan = 'Tujuan kamu';
  static const profileRowPolaKerja = 'Pola kerja';
  static const profileRowAturan = 'Aturan pribadi';
  static const profileRowBio = 'Bio';
  static const profileRowUsername = 'Username';
  static const profileRowName = 'Nama panggilan';
  static const profileRowNameHint = 'Yang Mori pakai untuk sapa kamu';
  static const profileRowEmail = 'Email';
  static const profileRowEmailHint = 'Tersinkron dengan akun Google';
  static const profileRowGoogle = 'Akun Google';
  static const profileRowPassword = 'Ubah password';
  static const profileRowTimezone = 'Zona waktu';
  static const profileRowNotification = 'Notifikasi';
  static const profileRowNotificationHint = 'Pengingat & aksi penting';
  static const profileRowLanguage = 'Bahasa Mori';
  static const profileRowLanguageValue = 'Bahasa Indonesia';
  static const profileRowThemeTitle = 'Mode tampilan';
  static const profileRowChatHistory = 'Riwayat chat dengan Mori';
  static const profileRowExport = 'Ekspor data';
  static const profileRowExportHint = 'Unduh semua agenda kamu';
  static const profileRowVersion = 'Versi';
  static const profileRowTerms = 'Syarat & ketentuan';
  static const profileRowPrivacy = 'Kebijakan privasi';
  static const profileRowFeedback = 'Beri masukan';
  static const profileRowLogout = 'Keluar dari akun';

  static const profileLockedPill = 'Tidak bisa diubah';
  static const profileGoogleConnectedPill = 'Terhubung';
  static const profileComingSoon = 'Segera hadir';
  static const profileBioEmpty = 'Belum diisi';
  static const profileBioEmptyHint = 'Tap untuk tambahkan';
  static const profileEmptyValue = '—';
  static const profileFooter =
      'Waktu kamu terbatas. Mori bantu pakai dengan lebih baik.';

  static const profileLogoutTitle = 'Keluar dari Mori?';
  static const profileLogoutBody =
      'Kamu akan kembali ke layar masuk. Jadwal Mori tetap aman.';

  static const profileThemeAutoHint = 'Ikuti pengaturan sistem';
  static const profileThemeLightHint = 'Terang sepanjang hari';
  static const profileThemeDarkHint = 'Gelap sepanjang hari';

  // Chat
  static const chatHeaderStatus = 'siap bantu';
  static const chatRestart = 'ulangi';
  static const chatComposerHint = 'Tulis pesan ke Mori…';

  static const chatTypingLabel1 = 'Mori berpikir';
  static const chatTypingLabel2 = 'merangkum konteks';
  static const chatTypingLabel3 = 'menyiapkan aksi';
  static const chatTypingLabel4 = 'menyelesaikan';

  static const actionIntentAdd = 'Tambah agenda';
  static const actionIntentEdit = 'Ubah agenda';
  static const actionIntentDelete = 'Hapus agenda';
  static const actionIntentToggle = 'Tandai selesai';

  static const actionCollisionTitle = 'Bentrok dengan jadwal';
  static const actionRevertHint =
      'Tekan tahan kartu untuk membatalkan keputusan.';

  // Nickname (06 Panggilan)
  static const nicknameTopTitle = 'Kenalan dulu';
  static const nicknameProgress = '1 dari 5';
  static const nicknameGreetingFirst = 'Halo! Aku Mori 👋';
  static const nicknameGreetingFallback =
      'Mau aku panggil kamu apa? Bisa diubah kapan saja di profil.';
  static const nicknameGreetingFormalLead = 'Email kamu terdaftar sebagai ';
  static const nicknameGreetingFormalTail =
      ' — tapi panggilan itu agak formal. Mau aku panggil kamu apa?';
  static const nicknameSuggestionsLabel = 'Saran dari nama kamu';
  static const nicknameOther = 'Lainnya';
  static const nicknamePreviewLead = 'Nanti aku sapa: ';
  static const nicknameFieldLabel = 'Panggilan kamu';
  static const nicknameFieldHint = 'Mis. Surya, Mas Surya, atau apapun';
  static const nicknameFieldHelp = 'Bisa diubah kapan saja di Profil.';
  static const nicknameSkip = 'Lewati';
  static const nicknameContinue = 'Lanjut';

  // Onboarding
  static const onboardingTopTitle = 'Kenalan dulu';
  static const onboardingHeroTitle = 'Mori perlu kenal kamu sedikit.';
  static const onboardingHeroSubtitle =
      'Supaya saran jadwal lebih pas dengan ritme kamu.';
  static const onboardingFieldProfesi = 'Profesi';
  static const onboardingFieldProfesiHint = 'Software Engineer';
  static const onboardingFieldTujuan = 'Tujuan kamu beberapa bulan ke depan';
  static const onboardingFieldTujuanHint =
      'Ship fitur baru sebelum akhir kuartal. Code review tim selesai dalam 24 jam.';
  static const onboardingFieldPolaKerja = 'Pola kerja';
  static const onboardingFieldPolaKerjaHint =
      'Senin-Jumat 09.00-18.00. Daily standup 09.30. Deep work 10.00-12.00. Meeting 14.00-17.00.';
  static const onboardingFieldAturan = 'Aturan pribadi';
  static const onboardingFieldAturanHint =
      'Tidak meeting Jumat sore. Code review pagi & sore.';
  static const onboardingFieldAturanHelp =
      'Boleh dikosongkan — bisa ditambahkan nanti.';
  static const onboardingFieldBio = 'Bio singkat';
  static const onboardingFieldBioHint =
      'Hybrid: WFO Senin-Rabu, WFH Kamis-Jumat. Hobi gym setelah jam kerja.';
  static const onboardingKembali = 'Kembali';
  static const onboardingSubmit = 'Selesai onboarding';
  static const onboardingSubmitting = 'Menyimpan…';
  static const onboardingFieldRequired = 'Wajib diisi.';
}
