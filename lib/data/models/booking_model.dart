enum ConsultationType { video, voice, inPerson }

class BookingModel {
  final String lawyerName;
  final String lawyerRole;
  final String lawyerPhoto;
  final String price;
  final int priceNum;
  final DateTime date;
  final String time;
  final ConsultationType type;
  final String? note;

  const BookingModel({
    required this.lawyerName,
    required this.lawyerRole,
    required this.lawyerPhoto,
    required this.price,
    required this.priceNum,
    required this.date,
    required this.time,
    required this.type,
    this.note,
  });

  String get typeLabel {
    switch (type) {
      case ConsultationType.video:
        return 'Video call';
      case ConsultationType.voice:
        return 'Voice call';
      case ConsultationType.inPerson:
        return 'In person';
    }
  }
}
