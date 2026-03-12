// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'ASConnexion';

  @override
  String get systemLanguage => 'Sistem';

  @override
  String get menu => 'Menu';

  @override
  String get menuNavigation => 'Navigasi';

  @override
  String get menuMyProfile => 'Profil saya';

  @override
  String get menuContact => 'Hubungi kami';

  @override
  String get menuPrivacyPolicy => 'Kebijakan privasi';

  @override
  String get menuVersion => 'Versi';

  @override
  String get menuContactSubject => 'Kontak melalui aplikasi';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String currentLanguage(String label) {
    return 'Saat ini: $label';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get ok => 'OK';

  @override
  String get logoutTitle => 'Keluar';

  @override
  String get logoutConfirm => 'Apakah Anda yakin ingin keluar dari aplikasi?';

  @override
  String get tabCommunity => 'Terhubung dengan komunitas';

  @override
  String get tabChats => 'Percakapan saya';

  @override
  String get tabPoi => 'Tempat menarik';

  @override
  String get profileUpdated => 'Profil diperbarui ✅';

  @override
  String get loginTitle => 'Masuk';

  @override
  String get loginIntro => 'Aplikasi ASConnect ditujukan hanya bagi para pendamping yang memiliki anak dengan sindrom Angelman, suatu penyakit genetik langka.';

  @override
  String get emailLabel => 'Alamat email';

  @override
  String get emailHintRequired => 'Masukkan email Anda';

  @override
  String get emailHintInvalid => 'Email tidak valid';

  @override
  String get passwordLabel => 'Kata sandi';

  @override
  String get show => 'Tampilkan';

  @override
  String get hide => 'Sembunyikan';

  @override
  String get passwordRequired => 'Masukkan kata sandi Anda';

  @override
  String get loginButton => 'Masuk';

  @override
  String get loginLoading => 'Sedang masuk…';

  @override
  String get createAccount => 'Buat akun';

  @override
  String get forgotPassword => 'Lupa kata sandi Anda?';

  @override
  String get invalidCredentials => 'Kredensial tidak valid.';

  @override
  String get accessDeniedKey => 'Akses ditolak: kunci aplikasi hilang atau tidak valid.';

  @override
  String get badRequest => 'Permintaan tidak valid (400).';

  @override
  String get tooManyAttempts => 'Terlalu banyak percobaan. Coba lagi sebentar lagi.';

  @override
  String get serviceUnavailable => 'Layanan tidak tersedia. Coba lagi nanti.';

  @override
  String serverErrorWithCode(int code) {
    return 'Kesalahan server ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Respons server tidak terduga.';

  @override
  String get cannotConnectServer => 'Tidak dapat terhubung ke server.';

  @override
  String get timeoutCheckConnection => 'Waktu habis. Periksa koneksi Anda.';

  @override
  String errorWithMessage(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String get missingAppKeyWarning => '⚠️ Kunci aplikasi tidak ada. Jalankan aplikasi dengan --dart-define=PUBLIC_APP_KEY=your_public_key';

  @override
  String get signupTitle => 'Buat akun';

  @override
  String get signupSectionPerson => 'Orang dengan SA';

  @override
  String get signupSectionAuth => 'Autentikasi';

  @override
  String get consentTitle => 'Persetujuan';

  @override
  String get firstNameLabel => 'Nama depan';

  @override
  String get firstNameRequired => 'Nama depan wajib diisi';

  @override
  String get lastNameLabel => 'Nama belakang';

  @override
  String get lastNameRequired => 'Nama belakang wajib diisi';

  @override
  String get birthdateLabel => 'Tanggal lahir (hh/bb/tttt)';

  @override
  String get birthdateRequired => 'Tanggal lahir wajib diisi';

  @override
  String get chooseDate => 'Pilih tanggal';

  @override
  String get signupBirthdateHelp => 'Tanggal lahir';

  @override
  String get genotypeLabel => 'Genotipe';

  @override
  String get genotypeRequired => 'Genotipe wajib diisi';

  @override
  String get genotypeDeletion => 'Delesi';

  @override
  String get genotypeMutation => 'Mutasi';

  @override
  String get genotypeUpd => 'UPD';

  @override
  String get genotypeIcd => 'ICD';

  @override
  String get genotypeClinical => 'Klinis';

  @override
  String get genotypeMosaic => 'Mosaik';

  @override
  String get signupPhotoHint => 'Foto anak (wajib, < 4 MB)';

  @override
  String get importPhoto => 'Impor foto';

  @override
  String get takePhoto => 'Ambil foto';

  @override
  String get deletePhoto => 'Hapus foto';

  @override
  String get signupPhotoRequired => 'Foto wajib';

  @override
  String get signupAddPhotoToContinue => 'Tambahkan foto untuk melanjutkan';

  @override
  String signupPhotoTooLarge(String mb) {
    return 'Ukuran foto melebihi 4 MB ($mb MB).';
  }

  @override
  String signupPhotoCannotLoad(String message) {
    return 'Tidak dapat mengambil foto: $message';
  }

  @override
  String get signupPasswordTooWeak => 'Kata sandi terlalu lemah';

  @override
  String get signupPwdRuleMin8 => 'Min. 8 karakter';

  @override
  String get signupPwdRuleUpper => '1 huruf besar';

  @override
  String get signupPwdRuleDigit => '1 angka';

  @override
  String get signupPwdRuleSpecial => '1 karakter khusus';

  @override
  String get secretQuestionLabel => 'Pertanyaan rahasia';

  @override
  String get secretQuestionRequired => 'Pertanyaan rahasia wajib diisi';

  @override
  String get secretQuestion1 => 'Nama keluarga ibu saat lahir?';

  @override
  String get secretQuestion2 => 'Nama aktor film favorit Anda?';

  @override
  String get secretQuestion3 => 'Nama hewan peliharaan favorit Anda?';

  @override
  String get secretAnswerLabel => 'Jawaban';

  @override
  String get secretAnswerRequired => 'Jawaban wajib diisi';

  @override
  String get consentCheckbox => 'Saya menyetujui syarat penggunaan data saya dan memberikan persetujuan saya.';

  @override
  String get signupConsentNotGiven => 'Anda belum memberikan persetujuan';

  @override
  String get signupCreating => 'Membuat…';

  @override
  String get signupCreateBtn => 'Buat akun saya';

  @override
  String get signupSuccess => 'Akun berhasil dibuat.';

  @override
  String get signupEmailAlreadyExistsRedirect => 'Email Anda sudah ada di basis data kami! Gunakan alamat email lain atau buka bagian lupa kata sandi.';

  @override
  String get signupSelectBirthdate => 'Pilih tanggal lahir';

  @override
  String get signupChooseGenotype => 'Pilih genotipe';

  @override
  String get signupChooseSecretQuestion => 'Pilih pertanyaan rahasia';

  @override
  String get signupEnterSecretAnswer => 'Masukkan jawaban rahasia';

  @override
  String signupApiFailed(int code, String body) {
    return 'API gagal ($code): $body';
  }

  @override
  String get forgotPasswordTitle => 'Lupa kata sandi';

  @override
  String get forgotEmailLabel => 'Alamat email';

  @override
  String get forgotFetchQuestionTooltip => 'Ambil pertanyaan';

  @override
  String get forgotEnterValidEmail => 'Masukkan email yang valid.';

  @override
  String get forgotUnknownEmail => 'Email tidak dikenal.';

  @override
  String forgotErrorCode(int code) {
    return 'Kesalahan ($code)';
  }

  @override
  String get forgotTimeoutRetry => 'Waktu habis. Coba lagi.';

  @override
  String forgotErrorWithMessage(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String get forgotQuestionFallback => 'Pertanyaan rahasia';

  @override
  String get forgotQuestionLabel => 'Pertanyaan';

  @override
  String get forgotSecretAnswerLabel => 'Jawaban rahasia';

  @override
  String get forgotAnswerRequired => 'Jawaban wajib diisi';

  @override
  String get forgotEnterYourAnswer => 'Masukkan jawaban Anda.';

  @override
  String get forgotVerify => 'Verifikasi';

  @override
  String get forgotAnswerCorrectSnack => 'Jawaban benar 👍';

  @override
  String forgotAnswerIncorrectAttempts(int attempts) {
    return 'Jawaban salah ($attempts/3).';
  }

  @override
  String forgotFailedAttempts(int attempts) {
    return 'Percobaan gagal: $attempts / 3';
  }

  @override
  String get forgotAnswerOkHint => '✅ Jawaban benar, Anda dapat memasukkan kata sandi baru.';

  @override
  String get forgotNewPasswordLabel => 'Kata sandi baru';

  @override
  String get forgotPasswordRequired => 'Kata sandi wajib diisi';

  @override
  String get forgotPasswordTooWeak => 'Kata sandi terlalu lemah';

  @override
  String get forgotPwdRuleMin8 => 'Setidaknya 8 karakter';

  @override
  String get forgotPwdRuleUpper => 'Setidaknya 1 huruf besar';

  @override
  String get forgotPwdRuleSpecial => 'Setidaknya 1 karakter khusus';

  @override
  String get forgotConfirmPasswordLabel => 'Konfirmasi kata sandi';

  @override
  String get forgotEnterNewPasswordFirst => 'Masukkan kata sandi baru terlebih dahulu';

  @override
  String get forgotPasswordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get forgotPasswordsMatch => 'Kata sandi cocok';

  @override
  String get forgotResetSuccess => 'Kata sandi berhasil diatur ulang ✅';

  @override
  String forgotResetFailed(int code) {
    return 'Gagal ($code).';
  }

  @override
  String get tooManyAttemptsTitle => 'Terlalu banyak percobaan';

  @override
  String get tooManyAttemptsMessage => 'Jumlah percobaan terlampaui.\n\nTulis ke contact@angelmananalytics.org untuk menjelaskan masalah koneksi Anda.';

  @override
  String get forgotValidating => 'Memvalidasi…';

  @override
  String get editProfileTitle => 'Ubah profil';

  @override
  String get loadingProfile => 'Memuat profil…';

  @override
  String get timeoutLoadingProfile => 'Waktu habis saat memuat profil.';

  @override
  String errorLoadingProfile(String message) {
    return 'Kesalahan saat memuat: $message';
  }

  @override
  String get import => 'Impor';

  @override
  String get deleteMyPhoto => 'Hapus foto saya';

  @override
  String get cancelSelection => 'Batalkan pilihan';

  @override
  String photoTooLarge(String size) {
    return 'Ukuran foto melebihi 4 MB ($size MB).';
  }

  @override
  String cannotGetPhoto(String message) {
    return 'Tidak dapat mengambil foto: $message';
  }

  @override
  String get photoRequired => 'Foto wajib';

  @override
  String get photoRequiredAddToSave => 'Tambahkan foto untuk menyimpan';

  @override
  String get photoRequiredAfterDelete => 'Foto wajib: impor atau ambil foto baru.';

  @override
  String get photoDeleted => 'Foto dihapus ✅';

  @override
  String get profileInfoSection => 'Informasi profil';

  @override
  String get firstName => 'Nama depan';

  @override
  String get lastName => 'Nama belakang';

  @override
  String get birthDateLabel => 'Tanggal lahir (hh/bb/tttt)';

  @override
  String get birthDateRequired => 'Tanggal lahir wajib diisi';

  @override
  String get genotype => 'Genotipe';

  @override
  String get city => 'Kota';

  @override
  String get geolocateMe => 'Geolokasikan saya';

  @override
  String get locationUpdated => 'Lokasi diperbarui';

  @override
  String locationUpdatedWithCity(String city) {
    return 'Lokasi diperbarui ($city)';
  }

  @override
  String get geolocation => 'Geolokasi';

  @override
  String get geolocationHint => 'Harap ubah geolokasi Anda jika lokasinya telah berubah sejak pendaftaran.';

  @override
  String get secretQuestionSection => 'Pertanyaan rahasia';

  @override
  String get question => 'Pertanyaan';

  @override
  String get answer => 'Jawaban';

  @override
  String get changeMyPassword => 'Ubah kata sandi saya';

  @override
  String get changePasswordTitle => 'Ubah kata sandi saya';

  @override
  String get newPasswordLabel => 'Kata sandi baru';

  @override
  String get confirmPasswordLabel => 'Konfirmasi kata sandi';

  @override
  String get passwordTooWeak => 'Kata sandi terlalu lemah';

  @override
  String get enterPassword => 'Masukkan kata sandi';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get passwordsMatch => 'Kata sandi cocok';

  @override
  String get pwdRuleMin8 => 'Setidaknya 8 karakter';

  @override
  String get pwdRuleUpper => 'Setidaknya 1 huruf besar';

  @override
  String get pwdRuleSpecial => 'Setidaknya 1 karakter khusus';

  @override
  String get passwordChanged => 'Kata sandi diubah ✅';

  @override
  String get save => 'Simpan';

  @override
  String get saving => 'Menyimpan…';

  @override
  String get savedChanges => 'Perubahan disimpan ✅';

  @override
  String get timeoutTryAgain => 'Waktu habis. Coba lagi.';

  @override
  String failedWithCode(int code) {
    return 'Gagal ($code)';
  }

  @override
  String get versionMadeByFastFrance => 'Aplikasi ini dibuat oleh Angelman Analytics (www.angelmananalytics.org)';

  @override
  String versionNumber(String version) {
    return 'Versi $version';
  }

  @override
  String get privacyTitle => 'Kebijakan privasi';

  @override
  String get privacyRightToBeForgotten => 'Hak untuk dilupakan';

  @override
  String get privacyDeleteTitle => 'Perhatian';

  @override
  String get privacyDeleteConfirmBody => 'Tindakan ini tidak dapat dibatalkan.\n\nProfil Anda dan data terkait akan dihapus secara permanen.\n\nApakah Anda ingin melanjutkan?';

  @override
  String get privacyDeletedOkTitle => 'Akun dihapus';

  @override
  String get privacyDeletedOkBody => 'Akun Anda telah berhasil dihapus.\nAnda akan diarahkan ke halaman masuk.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'Tidak dapat menghapus (kode $code).';
  }

  @override
  String get timeoutRetry => 'Waktu habis. Coba lagi.';

  @override
  String get consentText => 'Kebijakan privasi – Aplikasi ASConnect\n\n1) Identitas pengendali data\nData yang dikumpulkan dalam aplikasi ASConnect diproses oleh AngelmanAnalytics, sebagai pengendali data.\nUntuk setiap pertanyaan terkait data Anda atau pelaksanaan hak-hak Anda, Anda dapat menghubungi kami di: contact@angelmananalytics.org.\n____________________________________________\n2) Tujuan pemrosesan\nPemrosesan data yang dilakukan melalui aplikasi memiliki tujuan sebagai berikut:\no Pembuatan dan pengelolaan akun pengguna Anda untuk akses bernama ke aplikasi ASConnect;\no Penggunaan fitur geolokasi untuk menampilkan:\no Profil orang yang terdampak, menurut berbagai kriteria (jarak geografis, genotipe, kelompok usia);\no Peningkatan layanan dan personalisasi pengalaman pengguna, termasuk kemungkinan bagi pengguna.\no Ekstraksi data yang tidak memungkinkan identifikasi individu untuk tujuan statistik: jumlah orang dengan sindrom Angelman, distribusi berdasarkan usia...\n____________________________________________\n3) Kategori data yang dikumpulkan\nData berikut dapat dikumpulkan:\n• Data identifikasi:\no jenis kelamin, nama belakang, nama depan, alamat email, kata sandi, foto,\no pertanyaan dan jawaban rahasia (jika lupa kata sandi);\n• Data sensitif:\no genotipe, lokasi.\nDasar hukum untuk pemrosesan ini adalah persetujuan eksplisit dan terinformasi dari pengguna.\n____________________________________________\n4) Masa penyimpanan data\nData disimpan selama masa penggunaan akun, lalu dihapus paling lambat dalam 12 bulan setelah aktivitas terakhir.\nPengguna dapat kapan saja menggunakan hak untuk dilupakan langsung di aplikasi, melalui menu:\nKebijakan privasi → Hak untuk dilupakan.\n____________________________________________\n5) Penerima dan hosting data\nData dihosting secara aman di server PythonAnywhere.\nData disimpan di Uni Eropa.\n(Untuk informasi lebih lanjut tentang kebijakan perlindungan data penyedia hosting, lihat https://www.pythonanywhere.com/privacy/. )\nAplikasi web dihosting oleh O2Switch di Prancis, lihat https://www.o2switch.fr/du-rgpd.pdf.\n____________________________________________\n6) Hak pengguna\nSesuai dengan Peraturan (UE) 2016/679 (GDPR), pengguna memiliki hak berikut:\no Hak akses, perbaikan, dan penghapusan (“hak untuk dilupakan”) — langsung melalui profil mereka atau menu Kebijakan privasi → Hak untuk dilupakan;\no Hak untuk menolak, portabilitas, dan pembatasan pemrosesan;\no Hak untuk menarik persetujuan kapan saja.\nUntuk menggunakan hak-hak ini (selain hak untuk dilupakan yang tersedia dari aplikasi), Anda dapat mengirim email ke contact@angelmananalytics.org.\n____________________________________________\n7) Keamanan dan kerahasiaan\nSemua data dienkripsi selama penyimpanan dan transmisi.\nKata sandi di-hash sesuai praktik keamanan terbaik, dan semua komunikasi dengan layanan dilakukan melalui protokol HTTPS.\n____________________________________________\n8) Persetujuan eksplisit\nPendaftaran ke aplikasi ASConnect memerlukan persetujuan eksplisit dan terinformasi dari pengguna untuk pemrosesan yang dijelaskan pada bagian 2.\nPengguna dapat menarik persetujuan ini kapan saja melalui pengaturan akun mereka atau dengan menghubungi contact@angelmananalytics.org.\n____________________________________________\n9) Aturan penggunaan yang baik untuk pesan yang dipertukarkan\no Jangan mempublikasikan serangan atau komentar negatif mengenai kelompok. Setiap komentar yang bertujuan untuk melecehkan, merendahkan, mengancam, atau menyalahgunakan seseorang akan dihapus.\no Bersikaplah baik dan sopan. Kita semua terlibat dalam menciptakan lingkungan yang positif, informatif, dan penuh hormat. Perdebatan sehat adalah hal yang wajar, tetapi kebaikan wajib dijunjung.\no Tidak ada komentar yang tidak sopan. Intimidasi dalam bentuk apa pun tidak diizinkan dan komentar yang merendahkan tidak ditoleransi. Jangan mempublikasikan pernyataan yang menghina, mencemarkan nama baik, ofensif, atau penuh kekerasan.\no Penyampaian saran tidak boleh dianggap sebagai rekomendasi medis.\no Tidak ada iklan.\no Ketidakpatuhan terhadap aturan dapat menyebabkan administrator menghapus profil.';

  @override
  String get contactPageTitle => 'Hubungi kami';

  @override
  String get contactSendMessageTitle => 'Kirim pesan';

  @override
  String get contactSubjectLabel => 'Judul';

  @override
  String get contactSubjectHint => 'Subjek permintaan Anda';

  @override
  String get contactMessageLabel => 'Pesan';

  @override
  String get contactMessageHint => 'Jelaskan permintaan Anda…';

  @override
  String get contactAntiSpamTitle => 'Verifikasi anti-spam';

  @override
  String get contactRefresh => 'Segarkan';

  @override
  String contactCaptchaQuestion(int a, int b) {
    return 'Berapakah $a + $b?';
  }

  @override
  String get contactCaptchaAnswerLabel => 'Jawaban';

  @override
  String get contactCaptchaRequired => 'Captcha wajib diisi';

  @override
  String get contactCaptchaIncorrect => 'Captcha salah.';

  @override
  String get contactSend => 'Kirim';

  @override
  String get contactSending => 'Mengirim…';

  @override
  String get contactCancel => 'Batal';

  @override
  String get contactMessageSent => 'Pesan terkirim ✅';

  @override
  String contactSendFailedWithCode(int code) {
    return 'Gagal mengirim ($code)';
  }

  @override
  String get contactAccessDenied => 'Akses ditolak (kunci aplikasi hilang atau tidak valid).';

  @override
  String get contactTooManyRequests => 'Terlalu banyak permintaan. Coba lagi dalam beberapa detik.';

  @override
  String get contactServiceUnavailable => 'Layanan sementara tidak tersedia. Coba lagi nanti.';

  @override
  String get contactCheckInternet => 'Periksa koneksi internet Anda.';

  @override
  String get contactTimeout => 'Waktu habis. Coba lagi nanti.';

  @override
  String get contactFooterNote => 'Pesan Anda dikirim melalui API publik kami yang aman. Terima kasih!';

  @override
  String contactMissingAppKey(String command) {
    return '⚠️ Kunci aplikasi tidak ada. Jalankan aplikasi dengan $command';
  }

  @override
  String fieldRequired(String field) {
    return '$field wajib diisi';
  }

  @override
  String unexpectedError(String message) {
    return 'Kesalahan tak terduga: $message';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonConfirm => 'Konfirmasi';

  @override
  String get emailRequired => 'Email wajib diisi';

  @override
  String get emailInvalid => 'Email tidak valid';

  @override
  String get editProfileImport => 'Impor';

  @override
  String get editProfileTakePhoto => 'Ambil foto';

  @override
  String get editProfileDeletePhoto => 'Hapus foto saya';

  @override
  String get editProfileCancelSelection => 'Batalkan pilihan';

  @override
  String get editProfilePhotoRequired => 'Foto wajib';

  @override
  String get editProfilePhotoRequiredHint => 'Foto wajib: impor atau ambil foto baru.';

  @override
  String get editProfileAddPhotoToSave => 'Tambahkan foto untuk menyimpan';

  @override
  String get editProfilePhotoDeleted => 'Foto dihapus ✅';

  @override
  String editProfilePhotoTooLarge(String size) {
    return 'Ukuran foto melebihi 4 MB ($size MB).';
  }

  @override
  String editProfilePhotoPickError(String message) {
    return 'Tidak dapat mengambil foto: $message';
  }

  @override
  String get editProfileProfileInfoTitle => 'Informasi profil';

  @override
  String get editProfileFirstNameLabel => 'Nama depan';

  @override
  String get editProfileLastNameLabel => 'Nama belakang';

  @override
  String get editProfileEmailLabel => 'Alamat email';

  @override
  String get editProfileBirthDateLabel => 'Tanggal lahir (hh/bb/tttt)';

  @override
  String get editProfileBirthDateHelp => 'Tanggal lahir';

  @override
  String get editProfileBirthDatePickTooltip => 'Pilih tanggal';

  @override
  String get editProfileBirthDateRequired => 'Tanggal lahir wajib diisi';

  @override
  String get editProfileGenotypeLabel => 'Genotipe';

  @override
  String get editProfileGenotypeRequired => 'Genotipe wajib diisi';

  @override
  String get editProfileCityLabel => 'Kota';

  @override
  String get editProfileGeolocate => 'Geolokasikan saya';

  @override
  String get editProfileGeoTooltip => 'Harap ubah geolokasi Anda jika lokasinya telah berubah sejak pendaftaran.';

  @override
  String get geoTitle => 'Geolokasi';

  @override
  String get geoInfoText => 'Harap ubah geolokasi Anda jika lokasinya telah berubah sejak pendaftaran.';

  @override
  String editProfileLocationUpdated(String cityPart) {
    return 'Lokasi diperbarui$cityPart';
  }

  @override
  String get editProfileSecretSectionTitle => 'Pertanyaan rahasia';

  @override
  String get editProfileSecretQuestionLabel => 'Pertanyaan';

  @override
  String get editProfileSecretAnswerLabel => 'Jawaban rahasia';

  @override
  String get editProfileChangePassword => 'Ubah kata sandi saya';

  @override
  String get passwordEnterFirst => 'Masukkan kata sandi';

  @override
  String get passwordMismatch => 'Kata sandi tidak cocok';

  @override
  String get passwordMatch => 'Kata sandi cocok';

  @override
  String get editProfilePasswordChanged => 'Kata sandi diubah ✅';

  @override
  String get editProfileSave => 'Simpan';

  @override
  String get editProfileSaving => 'Menyimpan…';

  @override
  String get editProfileChangesSaved => 'Perubahan disimpan ✅';

  @override
  String get editProfileTimeoutLoading => 'Waktu habis saat memuat profil.';

  @override
  String editProfileLoadError(String message) {
    return 'Kesalahan saat memuat: $message';
  }

  @override
  String get editProfileTimeoutGeneric => 'Waktu habis. Coba lagi.';

  @override
  String editProfileErrorGeneric(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String get genotypeUPD => 'UPD';

  @override
  String get genotypeICD => 'ICD';

  @override
  String get secretQ1 => 'Nama keluarga ibu Anda saat lahir?';

  @override
  String get secretQ2 => 'Nama aktor film favorit Anda?';

  @override
  String get secretQ3 => 'Nama hewan peliharaan favorit Anda?';

  @override
  String get mapPersonTileIsMeHint => 'Ini profil Anda';

  @override
  String get mapPersonTileSendHint => 'Kirim pesan…';

  @override
  String get mapPersonTileCannotWriteTooltip => 'Tidak dapat menulis kepada Anda';

  @override
  String get mapPersonTileSendTooltip => 'Kirim';

  @override
  String mapPersonTileSendFailed(Object error) {
    return 'Gagal mengirim: $error';
  }

  @override
  String mapPersonTileAge(int age) {
    return '$age tahun';
  }

  @override
  String get mapFiltersButtonTooltip => 'Filter';

  @override
  String get mapNoFilters => 'Tidak ada filter';

  @override
  String mapGenotypeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genotipe',
      one: '$count genotipe',
    );
    return '$_temp0';
  }

  @override
  String mapAgeRangeYears(Object max, Object min) {
    return '$min–$max tahun';
  }

  @override
  String mapDistanceMaxKm(Object km) {
    return '≤ $km km';
  }

  @override
  String mapPeopleCountBanner(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orang',
      one: '$count orang',
    );
    return '$_temp0';
  }

  @override
  String get mapReloadFromNetworkTooltip => 'Muat ulang (jaringan, abaikan filter, perbarui cache)';

  @override
  String get mapTilesBlockedInReleaseMessage => 'Tile OSM dinonaktifkan di produksi.\nKonfigurasikan kunci MapTiler (atau gunakan allowOsmInRelease=true).';

  @override
  String get mapInitializingDataMessage => 'Kami sedang menginisialisasi seluruh data…';

  @override
  String mapNetworkUnavailableCacheUsed(Object error) {
    return 'Jaringan tidak tersedia — cache digunakan: $error';
  }

  @override
  String mapLoadGenericError(Object error) {
    return 'Kesalahan saat memuat: $error';
  }

  @override
  String mapFilterError(Object error) {
    return 'Kesalahan filter: $error';
  }

  @override
  String get mapLocationServiceDisabled => 'Layanan lokasi dinonaktifkan';

  @override
  String get mapLocationPermissionDenied => 'Izin lokasi ditolak';

  @override
  String mapLocationUnavailable(Object error) {
    return 'Lokasi tidak tersedia: $error';
  }

  @override
  String get mapPhotoViewerBarrierLabel => 'Foto';

  @override
  String get mapClose => 'Tutup';

  @override
  String mapCityPeopleCount(Object city, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orang',
      one: '$count orang',
    );
    return '$city • $_temp0';
  }

  @override
  String mapResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hasil',
      one: '$count hasil',
    );
    return '$_temp0';
  }

  @override
  String get mapNoResultsWithTheseFilters => 'Tidak ada hasil dengan filter ini (genotipe/jarak).';

  @override
  String get mapDistanceTitle => 'Jarak (dari posisi saya)';

  @override
  String get mapEnableDistanceFilter => 'Aktifkan filter jarak';

  @override
  String mapOriginDefined(Object lat, Object lon) {
    return 'Asal: $lat, $lon';
  }

  @override
  String get mapOriginUndefined => 'Asal: tidak ditentukan';

  @override
  String get mapMyPosition => 'Posisi saya';

  @override
  String mapKmLabel(Object km) {
    return '$km km';
  }

  @override
  String get mapGenotypeTitle => 'Genotipe';

  @override
  String get mapAgeTitle => 'Usia (tahun)';

  @override
  String mapMinValue(Object value) {
    return 'Min: $value';
  }

  @override
  String mapMaxValue(Object value) {
    return 'Maks: $value';
  }

  @override
  String get mapReset => 'Atur ulang';

  @override
  String get mapCancel => 'Batal';

  @override
  String get mapApply => 'Terapkan';

  @override
  String get mapCountryTitle => 'Negara';

  @override
  String get mapAllCountriesSelected => 'Semua negara';

  @override
  String mapCountriesSelectedCount(int count) {
    return '$count negara dipilih';
  }

  @override
  String get mapSelectAll => 'Pilih semua';

  @override
  String get mapClear => 'Batalkan semua';

  @override
  String get mapBack => 'Kembali';

  @override
  String chatWithName(Object name) {
    return 'Obrolan dengan $name';
  }

  @override
  String get conversationsReconnectToSee => 'Silakan masuk kembali untuk melihat percakapan Anda.';

  @override
  String get loading => 'Memuat…';

  @override
  String get conversationsEmpty => 'Tidak ada percakapan';

  @override
  String get conversationsNoMessage => 'Tidak ada pesan';

  @override
  String conversationsLoadError(Object error) {
    return 'Kesalahan saat memuat: $error';
  }

  @override
  String get conversationsLeaveTitle => 'Keluar dari percakapan?';

  @override
  String get conversationsLeaveBody => 'Apakah Anda yakin ingin keluar dari percakapan?\nSemua pesan Anda akan dihapus.';

  @override
  String get conversationsLeaveConfirm => 'Keluar';

  @override
  String get close => 'Tutup';

  @override
  String get photo => 'Foto';

  @override
  String get yesterday => 'kemarin';

  @override
  String genericError(Object error) {
    return 'Kesalahan: $error';
  }

  @override
  String get today => 'Hari ini';

  @override
  String get chatNoMessagesYet => 'Belum ada pesan untuk saat ini.';

  @override
  String chatLoadMessagesError(Object error) {
    return 'Kesalahan saat memuat pesan: $error';
  }

  @override
  String chatSendError(Object error) {
    return 'Kesalahan saat mengirim: $error';
  }

  @override
  String get chatEditMessageTitle => 'Ubah pesan';

  @override
  String get chatYourMessageHint => 'Pesan Anda';

  @override
  String chatEditError(Object error) {
    return 'Kesalahan saat mengubah: $error';
  }

  @override
  String get chatDeleteMessageTitle => 'Hapus pesan?';

  @override
  String get chatDeleteMessageBody => 'Pesan ini akan ditandai sebagai dihapus untuk percakapan ini.';

  @override
  String chatDeleteError(Object error) {
    return 'Kesalahan saat menghapus: $error';
  }

  @override
  String chatReactError(Object error) {
    return 'Kesalahan saat memberi reaksi: $error';
  }

  @override
  String get chatLeaveConversationBody => 'Apakah Anda yakin ingin keluar dari percakapan dan menghapus semua pesan Anda?';

  @override
  String chatLeaveError(Object error) {
    return 'Kesalahan saat keluar: $error';
  }

  @override
  String get message => 'Pesan';

  @override
  String get send => 'Kirim';

  @override
  String get edited => 'diubah';

  @override
  String get deletedMessage => 'Pesan dihapus';

  @override
  String get edit => 'Ubah';

  @override
  String get reply => 'Balas';

  @override
  String get delete => 'Hapus';

  @override
  String get languageName => 'Bahasa Indonesia';

  @override
  String get mapConnectionSectionTitle => 'Koneksi';

  @override
  String get mapConnectedOnlyLabel => 'Tampilkan hanya orang yang terhubung';

  @override
  String get mapConnectedOnlyHint => 'Sembunyikan profil offline.';

  @override
  String get mapConnectedOnlyChip => 'Terhubung';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get tableTabular => 'Tabel';

  @override
  String get tableColumnPseudo => 'Nama pengguna';

  @override
  String get tableColumnAge => 'Usia';

  @override
  String get tableColumnGenotype => 'Genotipe';

  @override
  String get tableColumnCountry => 'Negara';

  @override
  String get tableColumnCity => 'Kota';

  @override
  String get tabularColPseudo => 'Nama pengguna';

  @override
  String get tabularColAge => 'Usia';

  @override
  String get tabularColGenotype => 'Genotipe';

  @override
  String get tabularColCountry => 'Negara';

  @override
  String get tabularColCity => 'Kota';

  @override
  String get tabularColAction => 'Tindakan';

  @override
  String get tabularSendMessageTooltip => 'Kirim pesan';

  @override
  String get tabularSendMessageErrorNoId => 'Tidak dapat mengirim pesan: pengenal hilang.';

  @override
  String get tabularSendMessageActionStub => 'Fitur pesan belum terhubung.';

  @override
  String tabularSendMessageTitle(Object name) {
    return 'Pesan kepada $name';
  }

  @override
  String get tabularSendMessageHint => 'Tulis pesan…';

  @override
  String get tabularSendMessageSend => 'Kirim';

  @override
  String get tabularSendMessageSentStub => 'Pesan siap dikirim (belum dihubungkan).';

  @override
  String get tabularSendMessageCancel => 'Batal';

  @override
  String get genderLabel => 'Jenis kelamin';

  @override
  String get genderMale => 'Laki-laki';

  @override
  String get genderFemale => 'Perempuan';

  @override
  String get genderRequired => 'Silakan pilih jenis kelamin';

  @override
  String get acceptInfoAngelman => 'Saya setuju menerima informasi tentang sindrom Angelman';

  @override
  String get signupEnableGeolocation => 'Silakan izinkan geolokasi untuk melanjutkan.';

  @override
  String get signUpCheckMail => 'Memeriksa email';

  @override
  String get signUpGPS => 'Menentukan koordinat kota Anda dari posisi GPS';

  @override
  String get signUpMessageCreate => 'Membuat profil';

  @override
  String get tabGroup => 'Grup';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anggota',
      one: '$count anggota',
    );
    return '$_temp0';
  }

  @override
  String get groupCreateTooltip => 'Buat grup';

  @override
  String get groupCreateTitle => 'Buat grup';

  @override
  String get groupCreateIntro => 'Anda akan membuat grup. Silakan pilih judul yang bermakna, tulis pesan pertama, dan tentukan audiens melalui filter.';

  @override
  String get groupTitleLabel => 'Judul grup';

  @override
  String get groupFirstMessageLabel => 'Pesan pertama';

  @override
  String get groupCreateButton => 'Buat';

  @override
  String get groupTitleRequired => 'Judul wajib diisi';

  @override
  String get groupCreateNoMembers => 'Tidak dapat membuat grup tanpa anggota';

  @override
  String get audience => 'Audiens';

  @override
  String get profile => 'Profil';

  @override
  String get yearsOld => 'tahun';

  @override
  String get loadingGroup => 'Memuat...';

  @override
  String get mapLocationResolverMissing => 'Geolokasi tidak tersedia.';

  @override
  String get mapLocationUnableToGet => 'Tidak dapat memperoleh posisi. Periksa layanan GPS + izin.';

  @override
  String get groupDeleteTitle => 'Hapus grup?';

  @override
  String get groupDeleteBody => 'Tindakan ini akan menghapus percakapan grup secara permanen untuk semua anggota.';

  @override
  String get groupDeleteConfirm => 'Hapus';

  @override
  String get editProfilePhotoConverting => 'Sedang mengonversi…';

  @override
  String get mapLanguagesSectionTitle => 'Bahasa';

  @override
  String get mapAllLanguagesSelected => 'Semua bahasa';

  @override
  String mapLanguagesSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# bahasa',
      one: '# bahasa',
    );
    return '$_temp0';
  }
}
