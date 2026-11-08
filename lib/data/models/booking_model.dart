enum ConsultationType { video, voice, inPerson }

ConsultationType consultationTypeFromApi(String? v) {
  switch (v) {
    case 'voice': return ConsultationType.voice;
    case 'in_person': return ConsultationType.inPerson;
    case 'video':
    default: return ConsultationType.video;
  }
}

String consultationTypeToApi(ConsultationType t) {
  switch (t) {
    case ConsultationType.voice: return 'voice';
    case ConsultationType.inPerson: return 'in_person';
    case ConsultationType.video: return 'video';
  }
}

String _rupiah(dynamic v) {
  final n = v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  final s = (n / 1000).round();
  return 'Rp${s}rb';
}

class BookingModel {
  final String id;
  final String lawyerId;
  final String lawyerName;
  final String lawyerRole;
  final String lawyerPhoto;
  final String price;
  final int priceNum;
  final DateTime date;
  final String time;
  final ConsultationType type;
  final String? note;
  final String status;

  const BookingModel({
    this.id = '',
    this.lawyerId = '',
    required this.lawyerName,
    required this.lawyerRole,
    required this.lawyerPhoto,
    required this.price,
    required this.priceNum,
    required this.date,
    required this.time,
    required this.type,
    this.note,
    this.status = 'upcoming',
  });

  factory BookingModel.fromJson(Map<String, dynamic> j) {
    final lawyer = j['lawyer'] is Map ? Map<String, dynamic>.from(j['lawyer']) : const <String, dynamic>{};
    final dateStr = '${j['date'] ?? ''}';
    final parsedDate = DateTime.tryParse(dateStr.length == 10 ? '${dateStr}T00:00:00' : dateStr) ?? DateTime.now();
    final total = j['totalPrice'] ?? lawyer['pricePerHour'] ?? 0;
    final totalInt = total is num ? total.toInt() : int.tryParse('$total') ?? 0;
    return BookingModel(
      id: '${j['id'] ?? ''}',
      lawyerId: '${j['lawyerId'] ?? lawyer['id'] ?? ''}',
      lawyerName: '${lawyer['name'] ?? j['lawyerName'] ?? 'Pengacara'}',
      lawyerRole: '${lawyer['role'] ?? lawyer['specialty'] ?? j['lawyerRole'] ?? ''}',
      lawyerPhoto: '${lawyer['photoUrl'] ?? j['lawyerPhoto'] ?? ''}',
      price: j['price'] != null ? '${j['price']}' : _rupiah(totalInt),
      priceNum: totalInt > 0 ? (totalInt / 1000).round() : (j['priceNum'] is num ? (j['priceNum'] as num).toInt() : 0),
      date: parsedDate,
      time: '${j['time'] ?? ''}',
      type: consultationTypeFromApi('${j['type'] ?? 'video'}'),
      note: j['note']?.toString(),
      status: '${j['status'] ?? 'upcoming'}',
    );
  }

  String get typeLabel {
    switch (type) {
      case ConsultationType.video:
        return 'Panggilan video';
      case ConsultationType.voice:
        return 'Panggilan suara';
      case ConsultationType.inPerson:
        return 'Tatap muka';
    }
  }
}
