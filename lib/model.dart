import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class Attachment {
  final String name, category;
  final Uint8List bytes;
  Attachment(this.name, this.category, this.bytes);
  String get extension => name.split('.').last.toLowerCase();
}
class DemoRequest {
  final String id, project, amount, currency;
  final DateTime date;
  final Map<String, String> snapshot;
  final LatLng? location;
  final List<String> documents, photos;
  DemoRequest(this.id, this.project, this.amount, this.currency, this.date,
      this.snapshot, this.location, this.documents, this.photos);
}
class Notice {
  final String title, body;
  bool read = false;
  Notice(this.title, this.body);
}
class Ticket {
  final String id, kind, subject, body;
  Ticket(this.id, this.kind, this.subject, this.body);
}
class DemoState extends ChangeNotifier {
  String name = '', email = '', phone = '';
  final Map<String, String> data = {};
  final Set<String> completed = {};
  LatLng? location;
  final List<Attachment> documents = [], photos = [];
  final List<DemoRequest> requests = [];
  final List<Ticket> tickets = [];
  final List<Notice> notices = [Notice('مرحباً بك في تمويلي', 'يمكنك تجهيز طلب تمويل تجريبي ومتابعته من لوحة التحكم.')];
  int get unread => notices.where((n) => !n.read).length;
  void refresh() => notifyListeners();
  void mark(String route) { completed.add(route); refresh(); }
  String value(String key) => data[key] ?? '';
  void setValue(String key, String value) {
    if (data[key] == value) return;
    data[key] = value;
    completed.remove('/${key.split('.').first}');
    refresh();
  }
  void clearDraft() {
    data.clear(); completed.clear(); location = null; documents.clear(); photos.clear(); refresh();
  }
  DemoRequest submit() {
    final r = DemoRequest('TW-${(requests.length + 1).toString().padLeft(4, '0')}',
      value('project.name'), value('financial.amount'), value('financial.currency'), DateTime.now(),
      Map.unmodifiable(data), location, List.unmodifiable(documents.map((x) => x.name)), List.unmodifiable(photos.map((x) => x.name)));
    requests.insert(0, r);
    notices.insert(0, Notice('تم إرسال الطلب ${r.id}', 'تم تسجيل الطلب محلياً لأغراض العرض فقط.'));
    clearDraft(); return r;
  }
  void addTicket(String kind, String subject, String body) {
    final id = 'SUP-${tickets.length + 1}';
    tickets.insert(0, Ticket(id, kind, subject, body));
    notices.insert(0, Notice('تم تسجيل $kind', 'رقم المتابعة $id — محاكاة محلية.'));
    refresh();
  }
  void signOut() {
    name = ''; email = ''; phone = ''; requests.clear(); tickets.clear(); notices.clear();
    notices.add(Notice('مرحباً بك في تمويلي', 'يمكنك تجهيز طلب تمويل تجريبي.'));
    clearDraft();
  }
}
