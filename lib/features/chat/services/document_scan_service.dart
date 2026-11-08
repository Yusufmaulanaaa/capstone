import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../../data/models/chat_model.dart';

class DocumentScanService {
  const DocumentScanService();

  DocumentScanResult process({
    required String fileName,
    required Uint8List bytes,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Gambar dokumen tidak dapat dibaca.');
    }

    final original = decoded;
    final normalized = _normalizeSize(original, maxSide: 1400);
    final gray = img.grayscale(normalized);
    final denoised = img.gaussianBlur(gray, radius: 1);
    final contrasted = img.adjustColor(
      denoised,
      contrast: 1.25,
      brightness: 1.03,
      gamma: 1.0,
    );
    final threshold = _otsuThreshold(contrasted);
    final binary = _binarize(contrasted, threshold);
    final cleaned = img.convolution(binary, filter: [
      0,
      -1,
      0,
      -1,
      5,
      -1,
      0,
      -1,
      0,
    ]);
    final processed = img.copyResize(cleaned, width: cleaned.width);

    final metrics = _metrics(normalized);
    final textCoverage = _textCoverage(binary);
    final quality = _qualityLabel(metrics, textCoverage);
    final category = _detectCategory(fileName, metrics, textCoverage);
    final summary =
        _summary(fileName, category, quality, metrics, textCoverage);

    final processedBytes = Uint8List.fromList(img.encodePng(processed));
    final originalBytes = Uint8List.fromList(
      img.encodeJpg(_normalizeSize(original, maxSide: 900), quality: 88),
    );

    return DocumentScanResult(
      fileName: fileName,
      originalBytes: originalBytes,
      processedBytes: processedBytes,
      originalWidth: original.width,
      originalHeight: original.height,
      processedWidth: processed.width,
      processedHeight: processed.height,
      brightness: metrics.brightness,
      contrast: metrics.contrast,
      sharpness: metrics.sharpness,
      textCoverage: textCoverage,
      qualityLabel: quality,
      detectedCategory: category,
      pcdSteps: const [
        'Resize & normalisasi ukuran',
        'Grayscale',
        'Gaussian blur (reduksi noise)',
        'Penyesuaian kontras/brightness',
        'Threshold Otsu',
        'Binarisasi dokumen',
        'Sharpening/penajaman',
      ],
      summary: summary,
    );
  }

  img.Image _normalizeSize(img.Image src, {required int maxSide}) {
    final longest = math.max(src.width, src.height);
    if (longest <= maxSide) return src;
    final scale = maxSide / longest;
    return img.copyResize(
      src,
      width: (src.width * scale).round(),
      height: (src.height * scale).round(),
      interpolation: img.Interpolation.average,
    );
  }

  int _otsuThreshold(img.Image gray) {
    final hist = List<int>.filled(256, 0);
    int total = 0;
    for (final p in gray) {
      final v = p.r.toInt().clamp(0, 255);
      hist[v]++;
      total++;
    }
    double sum = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * hist[i];
    }
    double sumB = 0;
    int wB = 0;
    double maxVar = -1;
    int threshold = 128;
    for (int i = 0; i < 256; i++) {
      wB += hist[i];
      if (wB == 0) continue;
      final wF = total - wB;
      if (wF == 0) break;
      sumB += i * hist[i];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final between = wB * wF * (mB - mF) * (mB - mF);
      if (between > maxVar) {
        maxVar = between;
        threshold = i;
      }
    }
    return threshold;
  }

  img.Image _binarize(img.Image src, int threshold) {
    final out = img.Image.from(src);
    for (final p in out) {
      final v = p.r.toInt();
      final b = v > threshold ? 255 : 0;
      p
        ..r = b
        ..g = b
        ..b = b
        ..a = 255;
    }
    return out;
  }

  _ImageMetrics _metrics(img.Image src) {
    final g = img.grayscale(src);
    double sum = 0;
    double sumSq = 0;
    int n = 0;
    for (final p in g) {
      final v = p.r.toDouble();
      sum += v;
      sumSq += v * v;
      n++;
    }
    final mean = n == 0 ? 0.0 : sum / n;
    final variance = n == 0 ? 0.0 : (sumSq / n) - (mean * mean);
    final contrast = math.sqrt(variance < 0 ? 0 : variance) / 255.0;

    double lap = 0;
    int c = 0;
    for (int y = 1; y < g.height - 1; y++) {
      for (int x = 1; x < g.width - 1; x++) {
        final center = g.getPixel(x, y).r.toDouble();
        final v = (4 * center -
                g.getPixel(x - 1, y).r -
                g.getPixel(x + 1, y).r -
                g.getPixel(x, y - 1).r -
                g.getPixel(x, y + 1).r)
            .abs();
        lap += v;
        c++;
      }
    }
    final sharpness = c == 0 ? 0.0 : (lap / c) / 255.0;
    return _ImageMetrics(
      brightness: mean / 255.0,
      contrast: contrast.clamp(0.0, 1.0),
      sharpness: sharpness.clamp(0.0, 1.0),
    );
  }

  double _textCoverage(img.Image binary) {
    int dark = 0;
    int total = 0;
    for (final p in binary) {
      if (p.r.toInt() < 128) dark++;
      total++;
    }
    final ratio = total == 0 ? 0.0 : dark / total;
    // Heuristic: scanned text pages often have moderate dark pixel coverage.
    final centered = 1.0 - ((ratio - 0.12).abs() / 0.25);
    return centered.clamp(0.0, 1.0);
  }

  String _qualityLabel(_ImageMetrics m, double textCoverage) {
    final score = (m.contrast * 0.35) +
        (m.sharpness * 0.35) +
        ((1 - (m.brightness - 0.62).abs()).clamp(0.0, 1.0) * 0.15) +
        (textCoverage * 0.15);
    if (score >= 0.62) return 'Baik untuk analisis';
    if (score >= 0.42) return 'Cukup, bisa ditingkatkan';
    return 'Perlu foto ulang lebih jelas';
  }

  String _detectCategory(
      String fileName, _ImageMetrics m, double textCoverage) {
    final name = fileName.toLowerCase();
    if (name.contains('ktp') || name.contains('ident')) return 'Identitas/KTP';
    if (name.contains('transfer') || name.contains('bukti')) {
      return 'Bukti transaksi/pembayaran';
    }
    if (name.contains('surat') || name.contains('somasi')) {
      return 'Surat/somasi';
    }
    if (name.contains('chat') || name.contains('screenshot')) {
      return 'Screenshot percakapan';
    }
    if (textCoverage > 0.55 && m.contrast > 0.18) return 'Dokumen teks/cetakan';
    return 'Dokumen pendukung kasus';
  }

  String _summary(
    String fileName,
    String category,
    String quality,
    _ImageMetrics m,
    double textCoverage,
  ) {
    final tips = <String>[];
    if (m.brightness < 0.35) tips.add('pencahayaan kurang');
    if (m.brightness > 0.82) tips.add('terlalu terang/overexposed');
    if (m.contrast < 0.16) tips.add('kontras rendah');
    if (m.sharpness < 0.06) tips.add('gambar agak blur');
    final tipText = tips.isEmpty
        ? 'Kualitas visual cukup stabil untuk pratinjau.'
        : 'Saran: ${tips.join(', ')}.';
    return 'Dokumen "$fileName" terdeteksi sebagai $category. Hasil PCD: $quality. '
        'Cakupan area gelap/teks terestimasi ${(textCoverage * 100).toStringAsFixed(0)}%. '
        '$tipText\n\n'
        'Langkah aman: simpan dokumen asli, catat kronologi, dan hindari membagikan data sensitif. '
        'Ini analisis awal berbasis pengolahan citra (prototype), bukan nasihat hukum final.';
  }
}

class _ImageMetrics {
  final double brightness;
  final double contrast;
  final double sharpness;
  const _ImageMetrics({
    required this.brightness,
    required this.contrast,
    required this.sharpness,
  });
}
