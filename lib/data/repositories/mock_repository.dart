import 'package:flutter/material.dart';
import '../models/lawyer_model.dart';
import '../models/chat_model.dart';

// ──────────────────────────────────────────────
// Lawyers
// ──────────────────────────────────────────────

const List<LawyerModel> kLawyers = [
  LawyerModel(
    id: 'l1',
    name: 'Rizky Pratama, S.H.',
    role: 'Pengacara Pidana',
    city: 'Jakarta Selatan',
    rating: '4.9',
    ratingNum: 4.9,
    reviewCount: 128,
    exp: '9 tahun',
    cases: '240 kasus',
    price: 'Rp350rb/jam',
    priceNum: 350,
    photo: 'https://i.pravatar.cc/150?img=12',
    verified: true,
    about:
        'Rizky Pratama berpengalaman menangani perkara pidana umum dengan pendekatan strategis dan komunikatif. Fokus pada pembelaan klien, mediasi, dan penyusunan dokumen hukum yang kuat.',
    practiceAreas: [
      'Penipuan',
      'Penggelapan',
      'Pencurian',
      'Pendampingan BAP',
      'Pledoi & Replik'
    ],
    reviews: [
      ReviewModel(
          reviewer: 'Andi S.',
          photo: 'https://i.pravatar.cc/150?img=11',
          stars: 5,
          text: 'Penanganan kasus penipuan sangat cepat dan jelas arahnya.',
          date: 'Okt 2026'),
      ReviewModel(
          reviewer: 'Maya L.',
          photo: 'https://i.pravatar.cc/150?img=5',
          stars: 5,
          text: 'Responsif, profesional, dan membantu dari awal sampai akhir.',
          date: 'Sep 2026'),
      ReviewModel(
          reviewer: 'Rudi P.',
          photo: 'https://i.pravatar.cc/150?img=15',
          stars: 4,
          text: 'Penjelasan hukumnya mudah dipahami.',
          date: 'Agu 2026'),
    ],
  ),
  LawyerModel(
    id: 'l2',
    name: 'Nadia Kusuma, S.H., M.H.',
    role: 'Spesialis Pencemaran Nama Baik',
    city: 'Bandung',
    rating: '4.8',
    ratingNum: 4.8,
    reviewCount: 94,
    exp: '7 tahun',
    cases: '156 kasus',
    price: 'Rp300rb/jam',
    priceNum: 300,
    photo: 'https://i.pravatar.cc/150?img=47',
    verified: true,
    about:
        'Nadia Kusuma menangani sengketa reputasi, ujaran digital, dan pencemaran nama baik. Terbiasa menyusun somasi, mediasi, serta pendampingan laporan dengan bukti digital yang rapi.',
    practiceAreas: [
      'Pencemaran Nama Baik',
      'Ujaran Kebencian Digital',
      'Somasi',
      'Mediasi',
      'Perlindungan Reputasi'
    ],
    reviews: [
      ReviewModel(
          reviewer: 'Sari D.',
          photo: 'https://i.pravatar.cc/150?img=9',
          stars: 5,
          text: 'Kasus pencemaran nama baik saya ditangani tegas dan rapi.',
          date: 'Okt 2026'),
      ReviewModel(
          reviewer: 'Bima A.',
          photo: 'https://i.pravatar.cc/150?img=13',
          stars: 5,
          text: 'Somasinya efektif, masalah selesai lewat mediasi.',
          date: 'Sep 2026'),
      ReviewModel(
          reviewer: 'Lina R.',
          photo: 'https://i.pravatar.cc/150?img=44',
          stars: 4,
          text: 'Komunikatif dan detail soal bukti digital.',
          date: 'Jul 2026'),
    ],
  ),
  LawyerModel(
    id: 'l3',
    name: 'Dimas Ardiansyah, S.H.',
    role: 'Advokat Litigasi Pidana',
    city: 'Surabaya',
    rating: '4.7',
    ratingNum: 4.7,
    reviewCount: 76,
    exp: '6 tahun',
    cases: '132 kasus',
    price: 'Rp280rb/jam',
    priceNum: 280,
    photo: 'https://i.pravatar.cc/150?img=59',
    verified: true,
    about:
        'Dimas Ardiansyah fokus pada perkara penganiayaan, pencurian, dan pendampingan klien di tahap penyelidikan hingga persidangan. Mengutamakan kejelasan langkah hukum dan perlindungan hak klien.',
    practiceAreas: [
      'Penganiayaan',
      'Pencurian',
      'Penipuan',
      'Pendampingan Penyidikan',
      'Perdata Terkait Pidana'
    ],
    reviews: [
      ReviewModel(
          reviewer: 'Fajar W.',
          photo: 'https://i.pravatar.cc/150?img=70',
          stars: 5,
          text: 'Pendampingan kasus penganiayaan sangat membantu.',
          date: 'Okt 2026'),
      ReviewModel(
          reviewer: 'Nia K.',
          photo: 'https://i.pravatar.cc/150?img=49',
          stars: 4,
          text: 'Strateginya jelas dan transparan soal proses.',
          date: 'Sep 2026'),
      ReviewModel(
          reviewer: 'Tono B.',
          photo: 'https://i.pravatar.cc/150?img=67',
          stars: 5,
          text: 'Respons cepat saat proses penyidikan.',
          date: 'Agu 2026'),
    ],
  ),
];

const List<TopicModel> kTopics = [
  TopicModel(
      icon: Icons.phishing_outlined,
      title: 'Penipuan',
      sub: 'Modus tipu, transfer palsu, atau bukti chat/transaksi.'),
  TopicModel(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Penggelapan',
      sub: 'Dana/barang titipan disalahgunakan atau tidak dikembalikan.'),
  TopicModel(
      icon: Icons.lock_open_outlined,
      title: 'Pencurian',
      sub: 'Kehilangan barang, bukti CCTV/saksi, dan langkah laporan.'),
  TopicModel(
      icon: Icons.personal_injury_outlined,
      title: 'Penganiayaan',
      sub: 'Kekerasan fisik, visum, kronologi, dan perlindungan hukum.'),
  TopicModel(
      icon: Icons.campaign_outlined,
      title: 'Pencemaran Nama Baik',
      sub: 'Ujaran/fitnah di medsos, bukti digital, somasi atau laporan.'),
];

// Mock repositories (front-end only)
class LawyerRepository {
  Future<List<LawyerModel>> fetchLawyers() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return kLawyers;
  }

  Future<LawyerModel?> findById(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    try {
      return kLawyers.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}

class NotificationRepository {
  Future<List<NotificationModel>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<NotificationModel>.from(kNotifications);
  }
}

final kNotifications = <NotificationModel>[];
