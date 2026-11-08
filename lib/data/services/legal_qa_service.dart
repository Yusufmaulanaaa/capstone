import 'dart:math' as math;
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class QaRow {
  final String title;
  final String link;
  final String question;
  final String answer;
  final List<String> categories;
  final String searchText;
  QaRow(
      {required this.title,
      required this.link,
      required this.question,
      required this.answer,
      required this.categories,
      required this.searchText});
}

class ClassificationRow {
  final String text;
  final String category;
  ClassificationRow({required this.text, required this.category});
}

class DatasetHit {
  final QaRow row;
  final double score;
  DatasetHit(this.row, this.score);
}

class LegalQaResult {
  final String reply;
  final String intent;
  final String? category;
  final double score;
  final String? link;
  final String? question;
  final List<DatasetHit> hits;
  LegalQaResult(
      {required this.reply,
      required this.intent,
      this.category,
      required this.score,
      this.link,
      this.question,
      this.hits = const []});
}

class LegalQaService {
  static const qaAsset = 'assets/datasets/Indonesian_Legal_QA_543_Baris.csv';
  static const clsAsset =
      'assets/datasets/dataset_klasifikasi_kasus_hukum_500.csv';
  static const double _threshold = 0.02;

  List<QaRow> _qa = [];
  List<ClassificationRow> _cls = [];
  final Map<String, double> _qaIdf = {};
  final List<Map<String, double>> _qaVectors = [];
  final Map<String, double> _clsIdf = {};
  final List<Map<String, double>> _clsVectors = [];
  bool _loaded = false;
  Future<void>? _loading;

  bool get isReady => _loaded && _qa.isNotEmpty;
  int get qaCount => _qa.length;
  int get clsCount => _cls.length;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final qaRaw = await rootBundle.loadString(qaAsset);
      _qa = _parseQa(qaRaw);
    } catch (_) {
      _qa = [];
    }
    try {
      final clsRaw = await rootBundle.loadString(clsAsset);
      _cls = _parseCls(clsRaw);
    } catch (_) {
      _cls = [];
    }
    _buildQaIndex();
    _buildClsIndex();
    _loaded = true;
  }

  List<QaRow> _parseQa(String raw) {
    final rows = const CsvDecoder().convert(raw);
    if (rows.isEmpty) return [];
    final header = rows.first.map((e) => '$e'.trim().toLowerCase()).toList();
    int idx(String name, int fallback) {
      final i = header.indexWhere((h) => h == name || h.contains(name));
      return i >= 0 ? i : fallback;
    }

    final tI = idx('title', 0),
        lI = idx('link', 1),
        qI = idx('question', 2),
        aI = idx('answer', 3),
        cI = idx('kategori', 4);
    final out = <QaRow>[];
    for (var i = 1; i < rows.length; i++) {
      final r = rows[i];
      String get(int j) => j >= 0 && j < r.length ? '${r[j]}'.trim() : '';
      final question = get(qI);
      final answer = get(aI);
      if (question.isEmpty && answer.isEmpty) continue;
      final cats = get(cI)
          .split(';')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      out.add(QaRow(
          title: get(tI),
          link: get(lI),
          question: question,
          answer: answer,
          categories: cats,
          searchText: '$question ${get(tI)} $answer'));
    }
    return out;
  }

  List<ClassificationRow> _parseCls(String raw) {
    final rows = const CsvDecoder().convert(raw);
    if (rows.isEmpty) return [];
    final header = rows.first.map((e) => '$e'.trim().toLowerCase()).toList();
    int idx(String name, int fallback) {
      final i = header.indexWhere((h) => h == name || h.contains(name));
      return i >= 0 ? i : fallback;
    }

    final tI = idx('teks_laporan', 1), cI = idx('kategori', 2);
    final out = <ClassificationRow>[];
    for (var i = 1; i < rows.length; i++) {
      final r = rows[i];
      String get(int j) => j >= 0 && j < r.length ? '${r[j]}'.trim() : '';
      final text = get(tI);
      final cat = get(cI);
      if (text.isEmpty || cat.isEmpty) continue;
      out.add(ClassificationRow(text: text, category: cat));
    }
    return out;
  }

  List<String> _tokenize(String text) {
    final words = RegExp(r'[\p{L}\p{N}_]+', unicode: true)
        .allMatches(text.toLowerCase())
        .map((m) => m.group(0)!)
        .where((w) => w.length > 1)
        .toList();
    final grams = <String>[];
    for (var i = 0; i < words.length; i++) {
      grams.add(words[i]);
      if (i + 1 < words.length) grams.add('${words[i]} ${words[i + 1]}');
    }
    return grams;
  }

  Map<String, double> _vectorize(List<String> tokens, Map<String, double> idf) {
    final tf = <String, int>{};
    for (final t in tokens) {
      tf[t] = (tf[t] ?? 0) + 1;
    }
    final vec = <String, double>{};
    var norm = 0.0;
    tf.forEach((term, count) {
      final idfV = idf[term];
      if (idfV == null) return;
      final v = (1 + math.log(count)) * idfV;
      vec[term] = v;
      norm += v * v;
    });
    norm = math.sqrt(norm);
    if (norm > 0) {
      final keys = vec.keys.toList();
      for (final k in keys) {
        vec[k] = vec[k]! / norm;
      }
    }
    return vec;
  }

  void _buildIndex(List<String> docs, Map<String, double> idfOut,
      List<Map<String, double>> vecOut) {
    idfOut.clear();
    vecOut.clear();
    if (docs.isEmpty) return;
    final tokenized = docs.map(_tokenize).toList();
    final df = <String, int>{};
    for (final toks in tokenized) {
      for (final t in toks.toSet()) {
        df[t] = (df[t] ?? 0) + 1;
      }
    }
    final n = tokenized.length;
    df.forEach((term, c) {
      idfOut[term] = math.log((1 + n) / (1 + c)) + 1;
    });
    for (final toks in tokenized) {
      vecOut.add(_vectorize(toks, idfOut));
    }
  }

  void _buildQaIndex() =>
      _buildIndex(_qa.map((r) => r.searchText).toList(), _qaIdf, _qaVectors);
  void _buildClsIndex() =>
      _buildIndex(_cls.map((r) => r.text).toList(), _clsIdf, _clsVectors);

  double _cosine(Map<String, double> a, Map<String, double> b) {
    var s = 0.0;
    final small = a.length <= b.length ? a : b;
    final large = a.length <= b.length ? b : a;
    small.forEach((k, v) {
      final o = large[k];
      if (o != null) s += v * o;
    });
    return s;
  }

  String _intent(String text) {
    final t = text.toLowerCase().trim();
    final sapaan = [
      'hai',
      'halo',
      'hello',
      'hi',
      'selamat pagi',
      'selamat siang',
      'selamat sore',
      'selamat malam',
      'assalamualaikum'
    ];
    for (final k in sapaan) {
      if (RegExp('(?<![\\p{L}\\p{N}_])${RegExp.escape(k)}(?![\\p{L}\\p{N}_])',
                  unicode: true)
              .hasMatch(t) &&
          t.split(RegExp(r'\s+')).length <= 4) return 'sapaan';
    }
    if ([
      'mau konsultasi',
      'ingin konsultasi',
      'bisa konsultasi',
      'saya ingin bertanya'
    ].any(t.contains)) return 'konsultasi';
    if (['advokat', 'pengacara', 'bantuan hukum', 'lbh', 'cari pengacara']
            .any(t.contains) &&
        t.split(RegExp(r'\s+')).length <= 8) return 'rekomendasi_advokat';
    return 'laporan';
  }

  String? _predictCategory(String text) {
    if (_cls.isEmpty || _clsVectors.isEmpty) return _keywordCategory(text);
    final q = _vectorize(_tokenize(text), _clsIdf);
    if (q.isEmpty) return _keywordCategory(text);
    var best = -1;
    var bestS = -1.0;
    for (var i = 0; i < _clsVectors.length; i++) {
      final s = _cosine(q, _clsVectors[i]);
      if (s > bestS) {
        bestS = s;
        best = i;
      }
    }
    if (best >= 0 && bestS > 0.01) return _cls[best].category;
    return _keywordCategory(text);
  }

  String? _keywordCategory(String text) {
    final t = text.toLowerCase();
    if (t.contains('cema') ||
        t.contains('fitnah') ||
        t.contains('hoax') ||
        t.contains('nama baik')) return 'Pencemaran Nama Baik';
    if (t.contains('tipu') ||
        t.contains('scam') ||
        t.contains('investasi bodong') ||
        t.contains('transfer palsu')) return 'Penipuan';
    if (t.contains('gelap') ||
        t.contains('titipan') ||
        t.contains('tidak dikembalikan')) return 'Penggelapan';
    if (t.contains('curi') ||
        t.contains('maling') ||
        t.contains('ambil barang')) return 'Pencurian';
    if (t.contains('aniaya') ||
        t.contains('pukul') ||
        t.contains('kekerasan') ||
        t.contains('luka')) return 'Penganiayaan';
    return null;
  }

  List<DatasetHit> _search(String text, String? category) {
    if (_qa.isEmpty) return [];
    final q = _vectorize(_tokenize(text), _qaIdf);
    if (q.isEmpty) return [];
    final hits = <DatasetHit>[];
    for (var i = 0; i < _qa.length; i++) {
      final row = _qa[i];
      if (category != null && row.categories.isNotEmpty) {
        final catL = category.toLowerCase();
        final match = row.categories.any((c) =>
            c.toLowerCase().contains(catL) || catL.contains(c.toLowerCase()));
        if (!match) {
          /* soft filter: still allow but handled by score; skip strict filter to avoid empty */
        }
      }
      final s = _cosine(q, _qaVectors[i]);
      hits.add(DatasetHit(row, s));
    }
    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(5).toList();
  }

  String _trimAnswer(String a, int max) {
    var t = a.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max).trimRight()}…';
  }

  LegalQaResult answer(String message) {
    final pesan = message.trim();
    if (pesan.isEmpty) {
      return LegalQaResult(
          reply:
              'Silakan ceritakan masalah hukum yang ingin Anda konsultasikan.',
          intent: 'kosong',
          score: 0);
    }
    final intent = _intent(pesan);
    if (intent == 'sapaan') {
      return LegalQaResult(
          reply:
              'Halo! Selamat datang di layanan konsultasi hukum awal HukumIn.\n\nAnda bisa menceritakan masalah hukum atau menanyakan informasi hukum (penipuan, penggelapan, pencurian, penganiayaan, pencemaran nama baik, dan lainnya).',
          intent: intent,
          score: 0);
    }
    if (intent == 'konsultasi') {
      return LegalQaResult(
          reply:
              'Tentu, saya siap membantu konsultasi awal.\n\nAnda bisa:\n1. Menceritakan kronologi masalah hukum.\n2. Menyebutkan bukti yang dimiliki.\n3. Menanyakan langkah hukum yang mungkin ditempuh.\n\nCeritakan kebutuhan Anda terlebih dahulu.',
          intent: intent,
          score: 0);
    }
    if (intent == 'rekomendasi_advokat') {
      final cat = _predictCategory(pesan);
      return LegalQaResult(
          reply:
              'Saya bisa membantu mengarahkan pencarian bantuan hukum.${cat != null ? '\n\nKategori kasus terdeteksi: $cat.' : ''}\n\nUntuk rekomendasi pengacara terverifikasi, buka menu Konsultasi di aplikasi HukumIn atau ceritakan detail kasus agar saya bantu arahkan jenis spesialisasi yang tepat.',
          intent: intent,
          category: cat,
          score: 0);
    }
    if (!isReady) {
      return LegalQaResult(
          reply:
              'Dataset hukum lokal belum siap dimuat. Coba kirim pesan sekali lagi dalam beberapa saat.',
          intent: intent,
          score: 0);
    }
    final category = _predictCategory(pesan);
    final hits = _search(pesan, category);
    final best = hits.isNotEmpty ? hits.first : null;
    if (best == null || best.score < _threshold) {
      final label = category != null ? 'Kategori sementara: $category\n\n' : '';
      return LegalQaResult(
          reply:
              '${label}Saya belum menemukan jawaban yang cukup relevan di dataset lokal.\n\nAgar lebih tepat, ceritakan:\n1. Kronologi kejadian\n2. Waktu dan tempat\n3. Pihak yang terlibat\n4. Bukti/saksi yang ada\n\nAnda juga bisa unggah dokumen/bukti untuk analisis awal (PCD) di chat.',
          intent: intent,
          category: category,
          score: best?.score ?? 0,
          hits: hits);
    }
    final a = _trimAnswer(best.row.answer, 1500);
    final src = best.row.link.isNotEmpty ? best.row.link : '-';
    final reply =
        'Kategori hasil klasifikasi: ${category ?? (best.row.categories.isNotEmpty ? best.row.categories.first : '-')}\n\n'
        'Pertanyaan terkait:\n${best.row.question}\n\n'
        'Penjelasan hukum:\n$a\n\n'
        'Sumber: $src\n'
        'Skor kemiripan: ${best.score.toStringAsFixed(3)} (dataset QA ${_qa.length} baris, klasifikasi ${_cls.length} baris)\n\n'
        'Catatan: Jawaban ini diambil dari dataset Legal QA lokal berdasarkan kemiripan teks. Informasi ini merupakan bantuan awal dan bukan pengganti nasihat advokat.';
    return LegalQaResult(
        reply: reply,
        intent: intent,
        category: category,
        score: best.score,
        link: best.row.link.isNotEmpty ? best.row.link : null,
        question: best.row.question,
        hits: hits);
  }
}
