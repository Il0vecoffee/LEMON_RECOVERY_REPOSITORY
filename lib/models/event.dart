import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String desc;
  final DateTime date;
  final String? imageUrl;
  final String? externalLink;

  Event({
    required this.id,
    required this.title,
    required this.desc,
    required this.date,
    this.imageUrl,
    this.externalLink,
  });

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
      externalLink: map['externalLink'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'desc': desc,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'externalLink': externalLink,
    };
  }
}
