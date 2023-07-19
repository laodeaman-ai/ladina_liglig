# ladina_liglig
Paket ladina_liglig adalah paket perangkat lunak yang digunakan untuk melakukan serangkaian tugas dinamika molekular GROMACS untuk system LIGAN-LIGAN. Paket ini mencakup berbagai langkah yang diperlukan dalam dinamika molekuler mulai persiapan ligan, pembuatan file topologi, solvasi, ionisasi, minimisasi, ekuilibrasi, dan produksi.

Cara Penggunaan:
1. Pastikan Anda memiliki perangkat lunak GROMACS dan ACPYPE terinstal di sistem Anda.
2. Unduh dan ekstrak paket ladina_liglig ke direktori kerja Anda.
3. Masuk ke direktori kerja anda.
4. Pastikan file skrip ladina_liglig.sh memiliki izin eksekusi (chmod +x ladina_liglig.sh).
5. Siapkan direktori kompleks yang berisi ligan satu dan igan dua dalam format mol2.
6. Pastikan ligan satu dan ligan dua memiliki ID molekul (3 karakter angka, huruf kapital, atau kombinasinya) yang berbeda.
7. Tempatkan direktori kompleks ke dalam direktori kerja.
8. Jalankan skrip ladina_liglig.sh dengan perintah "./ladina_liglig.sh".
9. Tunggu hingga skrip menyelesaikan prosesnya. Hasil dan file output akan disimpan di masing-masing direktori kompleks.

Isi direktori:
- ladina_liglig.sh: Skrip utama untuk menjalankan langkah-langkah pemodelan molekuler dan simulasi molekuler pada ligan.
- README: File README ini yang berisi informasi tentang paket ladina_liglig.
- em.mdp: File konfigurasi untuk tahap minimisasi energi.
- ions.mdp: File konfigurasi untuk tahap penambahan ion.
- md.mdp: File konfigurasi untuk simulasi produksi.
- npt.mdp: File konfigurasi untuk tahap equilibrasi ensemble NPT.
- nvt.mdp: File konfigurasi untuk tahap equilibrasi ensemble NVT.

Catatan:
- Pastikan Anda sudah memahami dan memiliki pengetahuan dasar tentang GROMACS dan pemodelan molekuler sebelum menggunakan paket ini.
- Perhatikan bahwa paket ladina_liglig hanya dapat mengeksekusi system yang terdiri dari kompleks ligan-ligan. Termasuk dalam hal ini adalah kompleks polimer-ligan.

Kontak:
Developer: La Ode Aman
Email: laode_aman@ung.ac.id


