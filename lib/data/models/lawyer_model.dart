import 'package:flutter/material.dart';

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
