import 'package:flutter/material.dart';

const kGreen = Color(0xFF0E3B2E), kGold = Color(0xFFD4A63A);
const kFee = 30, kFree = 500, kMin = 50, kMax = 20000, kStep = 50;
// غيّر الأرقام دي لأرقام المحل
const kWa = '201025452408', kTel = '01025452408', kVcash = '01025452408';
const cats = ['الكل', 'بهارات', 'أعشاب وزهور', 'بذور وحبوب', 'عسل وزيوت'];
const catIcons = ['🛍️', '🧂', '🌿', '🌾', '🍯'];

class Product {
  final int id, price, color;
  final int? old;
  final String name, cat, desc;
  const Product(this.id, this.name, this.cat, this.color, this.price, this.old, this.desc);
  String get kind => id == 17 ? 'h' : (id == 18 ? 'o' : 'b');
  int get off => old == null ? 0 : ((1 - price / old!) * 100).round();
}

// الأسعار (جنيه للكيلو) والخصومات تجريبية
const products = <Product>[
  Product(1, 'كمون', 'بهارات', 0xFFB58A52, 220, 260, 'كمون مطحون بنكهة قوية، أساسي في الطبيخ واللحوم والشوربة.'),
  Product(2, 'كزبرة ناشفة', 'بهارات', 0xFFA8A55A, 150, null, 'كزبرة ناشفة مطحونة للمحشي والطواجن والشوربة.'),
  Product(3, 'فلفل أسود', 'بهارات', 0xFF3A3A3A, 480, null, 'فلفل أسود بنكهة حادة للتتبيل وكل أنواع الأكل.'),
  Product(4, 'قرفة أعواد', 'بهارات', 0xFFA0522D, 260, null, 'أعواد قرفة للمشروبات الساخنة والحلويات والأرز.'),
  Product(5, 'كركم', 'بهارات', 0xFFE0A800, 180, 230, 'كركم بلون ذهبي للأرز والدجاج والتتبيلات.'),
  Product(6, 'شطة حارة', 'بهارات', 0xFFC0392B, 160, null, 'شطة حارة مطحونة لمن يحب الأكل الحراق.'),
  Product(7, 'هيل حب', 'بهارات', 0xFF7FA650, 2200, null, 'هيل حب بنكهة عطرية للقهوة والشاي والحلويات.'),
  Product(8, 'بهارات مشكلة', 'بهارات', 0xFF9C6B3C, 200, null, 'خلطة بهارات جاهزة للأرز واللحوم والدجاج.'),
  Product(9, 'ينسون', 'أعشاب وزهور', 0xFFB9AE6A, 200, null, 'ينسون للمشروبات الساخنة والمخبوزات.'),
  Product(10, 'نعناع مجفف', 'أعشاب وزهور', 0xFF4F8A3C, 140, null, 'نعناع مجفف للشاي والشوربة والسلطات.'),
  Product(11, 'بابونج', 'أعشاب وزهور', 0xFFE9C94A, 320, null, 'زهور بابونج مجففة للمشروبات الساخنة.'),
  Product(12, 'كركديه', 'أعشاب وزهور', 0xFF9B1B30, 160, 190, 'كركديه مجفف للمشروب الساخن أو المثلج.'),
  Product(13, 'عرقسوس', 'أعشاب وزهور', 0xFF6B4423, 240, null, 'جذور عرقسوس لمشروب العرقسوس التقليدي.'),
  Product(14, 'حبة البركة', 'بذور وحبوب', 0xFF262626, 300, null, 'حبة البركة للمخبوزات والمخللات وتزيين الأكل.'),
  Product(15, 'حلبة', 'بذور وحبوب', 0xFFC98A2B, 90, null, 'حلبة حب لمشروب الحلبة وبعض الأطباق.'),
  Product(16, 'سمسم', 'بذور وحبوب', 0xFFE8DCC0, 200, null, 'سمسم للمخبوزات والحلويات والطحينة.'),
  Product(17, 'عسل نحل', 'عسل وزيوت', 0xFFE8A317, 650, 720, 'عسل نحل للفطار والمشروبات والحلويات.'),
  Product(18, 'زيت زيتون', 'عسل وزيوت', 0xFF9AA52E, 400, 460, 'زيت زيتون للسلطات والطبخ والتتبيل.'),
];

Product byId(int id) => products.firstWhere((p) => p.id == id);
int priceFor(Product p, int g) => (p.price * g / 1000).round();
String wl(int g) {
  if (g >= 1000 && g % 250 == 0) {
    final k = g / 1000;
    return '${k == k.roundToDouble() ? k.toInt() : k} كيلو';
  }
  return g == 500 ? '½ كيلو' : '$g جم';
}
String payName(String k) => k == 'cod' ? 'الدفع عند الاستلام' : 'فودافون كاش';
