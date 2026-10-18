import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

final app = AppState();

class AppState extends ChangeNotifier {
  late SharedPreferences p;
  Map<String, dynamic>? user;
  final cart = <int, int>{};
  final fav = <int>{};
  List<Map<String, dynamic>> orders = [];

  String get _ok => 'orders:${user?['phone'] ?? 'guest'}';

  Future<void> load() async {
    p = await SharedPreferences.getInstance();
    final u = p.getString('sess');
    if (u != null) user = Map<String, dynamic>.from(jsonDecode(u));
    final c = p.getString('cart');
    if (c != null) {
      (jsonDecode(c) as Map).forEach((k, v) => cart[int.parse(k as String)] = v as int);
    }
    fav.addAll((p.getStringList('fav') ?? []).map(int.parse));
    _loadOrders();
  }

  void _loadOrders() {
    final o = p.getString(_ok);
    orders = o == null ? [] : (jsonDecode(o) as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _save() {
    p.setString('cart', jsonEncode(cart.map((k, v) => MapEntry('$k', v))));
    p.setStringList('fav', fav.map((e) => '$e').toList());
    notifyListeners();
  }

  // ---- الحسابات (محفوظة على الجهاز فقط) ----
  String _h(String s) => sha256.convert(utf8.encode('khalifa:$s')).toString();
  Map<String, dynamic> _users() {
    final s = p.getString('users');
    return s == null ? {} : Map<String, dynamic>.from(jsonDecode(s));
  }

  String? register(String name, String phone, String pw) {
    final us = _users();
    if (us.containsKey(phone)) return 'الرقم ده مسجل قبل كده، سجّل دخولك';
    us[phone] = {'name': name, 'h': _h(pw)};
    p.setString('users', jsonEncode(us));
    _start({'name': name, 'phone': phone});
    return null;
  }

  String? login(String phone, String pw) {
    final u = _users()[phone] as Map?;
    if (u == null || u['h'] != _h(pw)) return 'رقم الموبايل أو كلمة السر غير صحيحة';
    _start({'name': u['name'], 'phone': phone});
    return null;
  }

  void guest() => _start({'name': 'زائر', 'guest': true});
  void _start(Map<String, dynamic> u) {
    user = u;
    p.setString('sess', jsonEncode(u));
    _loadOrders();
    notifyListeners();
  }

  void logout() {
    user = null;
    p.remove('sess');
    notifyListeners();
  }

  // ---- السلة بالجرام ----
  void add(int id, int g) {
    cart[id] = ((cart[id] ?? 0) + g).clamp(kMin, kMax).toInt();
    _save();
  }

  void step(int id, int d) {
    final g = (cart[id] ?? 0) + d * kStep;
    if (g < kMin) {
      cart.remove(id);
    } else {
      cart[id] = g.clamp(kMin, kMax).toInt();
    }
    _save();
  }

  void remove(int id) {
    cart.remove(id);
    _save();
  }

  void toggleFav(int id) {
    fav.contains(id) ? fav.remove(id) : fav.add(id);
    _save();
  }

  int get sub => cart.entries.fold(0, (t, e) => t + priceFor(byId(e.key), e.value));
  int get fee => (sub == 0 || sub >= kFree) ? 0 : kFee;

  Map<String, dynamic> place({required String name, required String phone, required String addr, required String note, required String pay, required String ref}) {
    final items = cart.entries.map((e) {
      final pr = byId(e.key);
      return {'n': pr.name, 'g': e.value, 't': priceFor(pr, e.value)};
    }).toList();
    final now = DateTime.now();
    final o = <String, dynamic>{
      'id': 'A${(now.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}',
      'date': '${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      'items': items, 'fee': fee, 'total': sub + fee, 'pay': pay, 'ref': ref,
      'name': name, 'phone': phone, 'addr': addr, 'note': note,
      'status': pay == 'cod' ? 'جديد' : 'في انتظار تأكيد التحويل',
    };
    orders.insert(0, o);
    p.setString(_ok, jsonEncode(orders));
    cart.clear();
    _save();
    return o;
  }

  String orderText(Map o) {
    final lines = (o['items'] as List).map((i) => '• ${i['n']} ${wl(i['g'] as int)} = ${i['t']} ج').join('\n');
    final fee = o['fee'] == 0 ? 'مجاني' : '${o['fee']} ج';
    final ref = o['ref'] == '' ? '' : ' (عملية ${o['ref']})';
    final note = o['note'] == '' ? '' : '\nملاحظات: ${o['note']}';
    return 'طلب جديد #${o['id']}\n$lines\nالتوصيل: $fee\nالإجمالي: ${o['total']} ج\n'
        'الدفع: ${payName(o['pay'])}$ref\nالاسم: ${o['name']}\nالموبايل: ${o['phone']}\nالعنوان: ${o['addr']}$note';
  }
}
