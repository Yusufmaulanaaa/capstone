import 'package:flutter/material.dart';

String _rupiahPerHour(dynamic v) {
  final n = v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  final s = (n / 1000).round();
  return 'Rp${s}rb/jam';
}

String _idStr(dynamic v) => '$v';
double _numD(dynamic v, [double d = 0]) => v is num ? v.toDouble() : double.tryParse('$v') ?? d;
int _numI(dynamic v, [int d = 0]) => v is num ? v.toInt() : int.tryParse('$v') ?? d;
List<String> _strList(dynamic v) => v is List ? v.map((e) => '$e').toList() : const <String>[];

class LawyerModel {
  final String id;
  final String name;
  final String role;
  final String city;
  final String rating;
  final double ratingNum;
  final int reviewCount;
  final String exp;
  final String cases;
  final String price;
  final int priceNum;
  final String photo;
  final String about;
  final List<String> practiceAreas;
  final List<ReviewModel> reviews;
  final bool verified;

  const LawyerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.city,
    required this.rating,
    required this.ratingNum,
    required this.reviewCount,
    required this.exp,
    required this.cases,
    required this.price,
    required this.priceNum,
    required this.photo,
    required this.about,
    required this.practiceAreas,
    required this.reviews,
    this.verified = true,
  });

  factory LawyerModel.fromJson(Map<String, dynamic> j) {
    final ratingNum = _numD(j['ratingNum'] ?? j['rating']);
    final experienceYears = _numI(j['experienceYears']);
    final casesHandled = _numI(j['casesHandled']);
    final pricePerHour = _numI(j['pricePerHour'] ?? j['priceNum']);
    final rawReviews = j['reviews'];
    return LawyerModel(
      id: _idStr(j['id']),
      name: '${j['name'] ?? ''}',
      role: '${j['role'] ?? j['specialty'] ?? 'Pengacara'}',
      city: '${j['city'] ?? '-'}',
      rating: (j['rating'] ?? ratingNum).toString(),
      ratingNum: ratingNum,
      reviewCount: _numI(j['reviewCount']),
      exp: j['exp'] != null ? '${j['exp']}' : (experienceYears > 0 ? '$experienceYears tahun' : '-'),
      cases: j['cases'] != null ? '${j['cases']}' : (casesHandled > 0 ? '$casesHandled kasus' : '-'),
      price: j['price'] != null ? '${j['price']}' : _rupiahPerHour(pricePerHour),
      priceNum: pricePerHour > 0 ? (pricePerHour / 1000).round() : _numI(j['priceNum']),
      photo: '${j['photo'] ?? j['photoUrl'] ?? ''}',
      about: '${j['about'] ?? ''}',
      practiceAreas: _strList(j['practiceAreas']).isNotEmpty ? _strList(j['practiceAreas']) : _strList(j['specialty']),
      reviews: rawReviews is List ? rawReviews.whereType<Map>().map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e))).toList() : const <ReviewModel>[],
      verified: j['verified'] == true,
    );
  }
}

class ReviewModel {
  final String reviewer;
  final String photo;
  final double stars;
  final String text;
  final String date;

  const ReviewModel({
    required this.reviewer,
    required this.photo,
    required this.stars,
    required this.text,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) {
    final created = DateTime.tryParse('${j['createdAt'] ?? j['date'] ?? ''}');
    return ReviewModel(
      reviewer: '${j['reviewer'] ?? j['userName'] ?? 'Pengguna'}',
      photo: '${j['photo'] ?? ''}',
      stars: _numD(j['stars'] ?? j['rating']),
      text: '${j['text'] ?? j['comment'] ?? ''}',
      date: j['date'] != null ? '${j['date']}' : (created == null ? '' : '${created.day}/${created.month}/${created.year}'),
    );
  }
}

class TopicModel {
  final IconData icon;
  final String title;
  final String sub;
  final bool hasDocument;

  const TopicModel({
    required this.icon,
    required this.title,
    required this.sub,
    this.hasDocument = false,
  });
}
