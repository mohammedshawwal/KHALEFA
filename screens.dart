import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'art.dart';
import 'data.dart';
import 'state.dart';

// ---------- أدوات مساعدة ----------
Future<void> openLink(BuildContext c, Uri u) async {
  var ok = false;
  try {
    ok = await launchUrl(u, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && c.mounted) toast(c, 'مش قادر أفتح الرابط على الجهاز ده');
}

Uri waUri(String text) => Uri.parse('https://wa.me/$kWa?text=${Uri.encodeComponent(text)}');
final callUri = Uri(scheme: 'tel', path: kTel);

void toast(BuildContext c, String m) => ScaffoldMessenger.of(c)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(m), duration: const Duration(milliseconds: 1500)));

void copyText(BuildContext c, String t) {
  Clipboard.setData(ClipboardData(text: t));
  toast(c, 'تم النسخ ✓');
}

void showContact(BuildContext c) {
  showModalBottomSheet(
    context: c,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('تواصل مع عطارة خليفة العطار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Directionality(textDirection: TextDirection.ltr, child: Text(kTel, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        const SizedBox(height: 14),
        FilledButton.icon(onPressed: () => openLink(ctx, callUri), icon: const Icon(Icons.call), label: const Text('اتصال')),
        const SizedBox(height: 8),
        FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white),
            onPressed: () => openLink(ctx, Uri.parse('https://wa.me/$kWa')),
            icon: const Icon(Icons.chat),
            label: const Text('واتساب')),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () => copyText(ctx, kTel), icon: const Icon(Icons.copy), label: const Text('نسخ الرقم')),
      ]),
    ),
  );
}

class Box extends StatelessWidget {
  final Widget child;
  final EdgeInsets pad;
  const Box(this.child, {super.key, this.pad = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext c) {
    final t = Theme.of(c);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: pad,
      decoration: BoxDecoration(color: t.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.dividerColor)),
      child: child,
    );
  }
}

class Medal extends StatelessWidget {
  final double s;
  const Medal(this.s, {super.key});
  @override
  Widget build(BuildContext c) => Container(
        width: s,
        height: s,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kGold, width: 2)),
        child: Text('خ', style: TextStyle(color: kGold, fontSize: s * .55, fontWeight: FontWeight.bold)),
      );
}

// ---------- تسجيل الدخول ----------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  bool reg = false, hide = true;
  String? err;
  final n = TextEditingController(), ph = TextEditingController(), pw = TextEditingController();

  void submit() {
    final name = n.text.trim(), phone = ph.text.trim();
    String? e;
    if (reg && name.length < 3) {
      e = 'اكتب اسمك';
    } else if (!RegExp(r'^01[0125]\d{8}$').hasMatch(phone)) {
      e = 'اكتب رقم موبايل مصري صحيح من 11 رقم';
    } else if (reg && pw.text.length < 6) {
      e = 'كلمة السر لازم تكون 6 حروف أو أرقام على الأقل';
    } else {
      e = reg ? app.register(name, phone, pw.text) : app.login(phone, pw.text);
    }
    if (e != null) setState(() => err = e);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 36),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [kGreen, Color(0xFF1F6B52)], begin: Alignment.topRight, end: Alignment.bottomLeft)),
              child: const Column(children: [
                Medal(84),
                SizedBox(height: 14),
                Text('عطارة خليفة العطار', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('بهارات وأعشاب وعسل… لحد باب بيتك', style: TextStyle(color: Colors.white70)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SegmentedButton<bool>(
                  segments: const [ButtonSegment(value: false, label: Text('تسجيل الدخول')), ButtonSegment(value: true, label: Text('حساب جديد'))],
                  selected: {reg},
                  onSelectionChanged: (s) => setState(() {
                    reg = s.first;
                    err = null;
                  }),
                ),
                const SizedBox(height: 14),
                if (reg) ...[TextField(controller: n, decoration: const InputDecoration(labelText: 'الاسم')), const SizedBox(height: 12)],
                TextField(controller: ph, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الموبايل', hintText: '01xxxxxxxxx')),
                const SizedBox(height: 12),
                TextField(
                  controller: pw,
                  obscureText: hide,
                  decoration: InputDecoration(labelText: 'كلمة السر', suffixIcon: IconButton(icon: Icon(hide ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => hide = !hide))),
                ),
                if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 18),
                FilledButton(onPressed: submit, child: Text(reg ? 'إنشاء الحساب' : 'دخول')),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: app.guest, child: const Text('تصفح كزائر')),
              ]),
            ),
          ]),
        ),
      );
}

// ---------- الهيكل الرئيسي ----------
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (c, _) => Scaffold(
          body: Stack(children: [
            IndexedStack(index: i, children: const [HomePage(), CartPage(), OrdersPage(), AccountPage()]),
            if (i == 0 && app.cart.isNotEmpty)
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Material(
                  color: kGreen,
                  elevation: 6,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => i = 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Text('🧺 ${app.cart.length} صنف · ${app.sub} ج', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const Text('عرض السلة', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ),
              ),
          ]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: i,
            onDestinationSelected: (v) => setState(() => i = v),
            destinations: [
              const NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'المنتجات'),
              NavigationDestination(icon: Badge(isLabelVisible: app.cart.isNotEmpty, label: Text('${app.cart.length}'), child: const Icon(Icons.shopping_basket_outlined)), selectedIcon: const Icon(Icons.shopping_basket), label: 'السلة'),
              const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'طلباتي'),
              const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
            ],
          ),
        ),
      );
}

// ---------- الرئيسية ----------
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  int cat = 0, sort = 0;
  String q = '';

  Widget title(String t, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (trailing != null) trailing,
        ]),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (c, _) {
          final l = products.where((p) => (cat == 0 || p.cat == cats[cat]) && (q.isEmpty || p.name.contains(q))).toList();
          if (sort == 1) l.sort((a, b) => a.price.compareTo(b.price));
          if (sort == 2) l.sort((a, b) => b.price.compareTo(a.price));
          final home = q.isEmpty && cat == 0;
          final deals = products.where((p) => p.off > 0).toList();
          return CustomScrollView(slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
              toolbarHeight: 64,
              titleSpacing: 12,
              title: Row(children: [
                const Medal(40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('عطارة خليفة العطار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(app.user?['guest'] == true ? 'أهلًا بيك' : 'أهلًا ${app.user?['name'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ]),
                ),
              ]),
              actions: [
                IconButton(onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const FavPage())), icon: Badge(isLabelVisible: app.fav.isNotEmpty, label: Text('${app.fav.length}'), child: const Icon(Icons.favorite_border))),
                IconButton(onPressed: () => showContact(c), icon: const Icon(Icons.call)),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(58),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: TextField(
                    onChanged: (v) => setState(() => q = v.trim()),
                    decoration: InputDecoration(hintText: 'ابحث عن كمون، ينسون، عسل…', prefixIcon: const Icon(Icons.search), isDense: true, fillColor: Theme.of(c).colorScheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                ),
              ),
            ),
            if (home) SliverToBoxAdapter(child: Banners((i) => setState(() => cat = i))),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  itemCount: cats.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => setState(() => cat = i),
                    child: SizedBox(
                      width: 66,
                      child: Column(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(c).colorScheme.surface, border: Border.all(color: i == cat ? kGold : Theme.of(c).dividerColor, width: 2)),
                          child: Text(catIcons[i], style: const TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(height: 4),
                        Text(cats[i], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: i == cat ? FontWeight.bold : FontWeight.normal)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
            if (home) ...[
              SliverToBoxAdapter(child: title('عروض اليوم')),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 292,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: deals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(width: 160, child: ProductCard(deals[i], tag: 'd')),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: title(q.isNotEmpty ? 'نتائج البحث' : (cat == 0 ? 'كل المنتجات' : cats[cat]),
                  trailing: DropdownButton<int>(
                    value: sort,
                    underline: const SizedBox.shrink(),
                    items: const [DropdownMenuItem(value: 0, child: Text('الترتيب')), DropdownMenuItem(value: 1, child: Text('الأرخص أولًا')), DropdownMenuItem(value: 2, child: Text('الأغلى أولًا'))],
                    onChanged: (v) => setState(() => sort = v ?? 0),
                  )),
            ),
            if (l.isEmpty)
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(24), child: Text('مفيش منتج بالاسم ده. جرّب كلمة تانية.')))
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 6, 16, app.cart.isEmpty ? 16 : 80),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .54),
                  delegate: SliverChildBuilderDelegate((_, i) => ProductCard(l[i], tag: 'g'), childCount: l.length),
                ),
              ),
          ]);
        },
      );
}

class Banners extends StatefulWidget {
  final void Function(int) onCat;
  const Banners(this.onCat, {super.key});
  @override
  State<Banners> createState() => _BannersState();
}

class _BannersState extends State<Banners> {
  final pc = PageController();
  Timer? t;
  int i = 0;
  static const slides = [
    ['توصيل مجاني', 'للطلبات فوق $kFree ج', 0xFF0E3B2E, 0xFF1F6B52, 5, 0],
    ['أعشاب ومشروبات', 'ينسون · نعناع · بابونج', 0xFF5B3A12, 0xFFB27A22, 11, 2],
    ['عسل وزيوت', 'للفطار والطبخ والسلطات', 0xFF6E1D2F, 0xFFB13D55, 17, 4],
  ];
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!pc.hasClients) return;
      i = (i + 1) % slides.length;
      pc.animateToPage(i, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    t?.cancel();
    pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 160,
        child: PageView(
          controller: pc,
          children: [
            for (final s in slides)
              GestureDetector(
                onTap: () => widget.onCat(s[5] as int),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(colors: [Color(s[2] as int), Color(s[3] as int)])),
                  child: Row(children: [
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s[0] as String, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(s[1] as String, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 10),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5), decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(99)), child: const Text('تسوّق الآن', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A1E00)))),
                      ]),
                    ),
                    SizedBox(width: 120, child: ProductArt(byId(s[4] as int))),
                  ]),
                ),
              ),
          ],
        ),
      );
}

class ProductCard extends StatelessWidget {
  final Product p;
  final String tag;
  const ProductCard(this.p, {super.key, this.tag = 'g'});
  @override
  Widget build(BuildContext c) {
    final t = Theme.of(c), fav = app.fav.contains(p.id);
    return GestureDetector(
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => ProductPage(p, tag))),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: t.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.dividerColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: Stack(children: [
              Positioned.fill(child: Container(color: Color(p.color).withOpacity(.2), padding: const EdgeInsets.all(10), child: Hero(tag: '$tag${p.id}', child: ProductArt(p)))),
              if (p.off > 0)
                Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFA3223B), borderRadius: BorderRadius.circular(8)), child: Text('-${p.off}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
              Positioned(top: 2, left: 2, child: IconButton(iconSize: 20, onPressed: () => app.toggleFav(p.id), icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.red : Colors.black45))),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(p.cat, style: TextStyle(fontSize: 12, color: t.hintColor)),
                const Spacer(),
                Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                  Text('${p.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(' ج/كيلو', style: TextStyle(fontSize: 11, color: t.hintColor)),
                  if (p.old != null) Text('  ${p.old}', style: TextStyle(fontSize: 12, color: t.hintColor, decoration: TextDecoration.lineThrough)),
                ]),
                const SizedBox(height: 6),
                SizedBox(
                  height: 34,
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero, backgroundColor: kGold, foregroundColor: const Color(0xFF2A1E00)),
                    onPressed: () {
                      app.add(p.id, 250);
                      toast(c, 'تمت الإضافة · 250 جم ✓');
                    },
                    child: const Text('+ أضف 250 جم', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class FavPage extends StatelessWidget {
  const FavPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('المفضلة')),
        body: ListenableBuilder(
          listenable: app,
          builder: (c, _) {
            final l = app.fav.map(byId).toList();
            if (l.isEmpty) return const Center(child: Text('اضغط على القلب في أي منتج علشان تلاقيه هنا.'));
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .54),
              itemCount: l.length,
              itemBuilder: (_, i) => ProductCard(l[i], tag: 'f'),
            );
          },
        ),
      );
}

// ---------- صفحة المنتج (تحديد الكمية بالجرام) ----------
class ProductPage extends StatefulWidget {
  final Product p;
  final String tag;
  const ProductPage(this.p, this.tag, {super.key});
  @override
  State<ProductPage> createState() => _ProductState();
}

class _ProductState extends State<ProductPage> {
  int g = 250;
  late final ctl = TextEditingController(text: '250');

  void setG(int v, {bool text = true}) {
    setState(() => g = v.clamp(kMin, kMax).toInt());
    if (text) ctl.text = '$g';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p, t = Theme.of(context);
    final u = priceFor(p, g), o = p.old == null ? 0 : (p.old! * g / 1000).round();
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 260,
          actions: [ListenableBuilder(listenable: app, builder: (c, _) => IconButton(onPressed: () => app.toggleFav(p.id), icon: Icon(app.fav.contains(p.id) ? Icons.favorite : Icons.favorite_border, color: app.fav.contains(p.id) ? Colors.red : null)))],
          flexibleSpace: FlexibleSpaceBar(background: Container(color: Color(p.color).withOpacity(.25), padding: const EdgeInsets.fromLTRB(60, 70, 60, 16), child: Hero(tag: '${widget.tag}${p.id}', child: ProductArt(p)))),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.cat, style: TextStyle(color: t.hintColor)),
              Text(p.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                Text('$u ج', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                if (o > 0) ...[Text('   $o', style: TextStyle(color: t.hintColor, decoration: TextDecoration.lineThrough)), Text('   وفّر ${o - u} ج', style: const TextStyle(color: Color(0xFFA3223B), fontWeight: FontWeight.bold))],
              ]),
              Text('سعر الكيلو ${p.price} ج', style: TextStyle(color: t.hintColor)),
              const SizedBox(height: 14),
              Box(Column(children: [
                const Align(alignment: Alignment.centerRight, child: Text('حدد الكمية اللي تحتاجها', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton.filled(onPressed: () => setG(g + kStep), icon: const Icon(Icons.add)),
                  Container(
                    width: 130,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: ctl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(suffixText: 'جرام'),
                      onChanged: (v) => setG(int.tryParse(v) ?? 0, text: false),
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();
                        ctl.text = '$g';
                      },
                    ),
                  ),
                  IconButton.filled(onPressed: () => setG(g - kStep), icon: const Icon(Icons.remove)),
                ]),
                const SizedBox(height: 6),
                Text('= ${wl(g)}', style: TextStyle(color: t.hintColor)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [for (final w in [100, 250, 500, 1000, 2000]) ChoiceChip(label: Text(wl(w)), selected: g == w, onSelected: (_) => setG(w))]),
              ])),
              Box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('عن المنتج', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(p.desc, style: TextStyle(color: t.hintColor)),
                const SizedBox(height: 8),
                Text('⚖️ اكتب الوزن بالجرام وهنجهزه ليك بالظبط (من $kMin جم)'),
                const Text('🚚 توصيل لحد باب البيت'),
                const Text('💳 دفع عند الاستلام أو فودافون كاش'),
              ])),
            ]),
          ),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(color: t.colorScheme.surface, border: Border(top: BorderSide(color: t.dividerColor))),
          child: Row(children: [
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('الإجمالي', style: TextStyle(fontSize: 12, color: t.hintColor)),
              Text('$u ج', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  app.add(p.id, g);
                  toast(context, 'تمت الإضافة · ${wl(g)} ✓');
                },
                child: const Text('أضف للسلة'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kGold, foregroundColor: const Color(0xFF2A1E00)),
                onPressed: () {
                  app.add(p.id, g);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage()));
                },
                child: const Text('اشتر الآن'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------- السلة ----------
class Totals extends StatelessWidget {
  const Totals({super.key});
  @override
  Widget build(BuildContext c) => Box(Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المجموع'), Text('${app.sub} ج', style: const TextStyle(fontWeight: FontWeight.bold))]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('التوصيل'), Text(app.fee == 0 ? 'مجاني' : '${app.fee} ج', style: const TextStyle(fontWeight: FontWeight.bold))]),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('${app.sub + app.fee} ج', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
      ]));
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (c, _) {
          if (app.cart.isEmpty) return const Center(child: Text('🧺\nالسلة فاضية\nاختار من العطارة وحدد الكمية اللي تحتاجها.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.8)));
          final r = kFree - app.sub;
          return SafeArea(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              const Text('سلة المشتريات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r > 0 ? 'أضف بـ $r ج واحصل على توصيل مجاني' : '🎉 التوصيل مجاني على طلبك'),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: (app.sub / kFree).clamp(0, 1).toDouble(), minHeight: 8, color: kGold)),
              ])),
              for (final e in app.cart.entries)
                Dismissible(
                  key: ValueKey(e.key),
                  onDismissed: (_) => app.remove(e.key),
                  child: Box(Row(children: [
                    SizedBox(width: 68, child: ProductArt(byId(e.key))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(byId(e.key).name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${byId(e.key).price} ج / كيلو', style: TextStyle(fontSize: 12, color: Theme.of(c).hintColor)),
                        Text('${priceFor(byId(e.key), e.value)} ج', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Row(children: [
                          IconButton.filledTonal(visualDensity: VisualDensity.compact, onPressed: () => app.step(e.key, 1), icon: const Icon(Icons.add)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(wl(e.value), style: const TextStyle(fontWeight: FontWeight.bold))),
                          IconButton.filledTonal(visualDensity: VisualDensity.compact, onPressed: () => app.step(e.key, -1), icon: const Icon(Icons.remove)),
                        ]),
                      ]),
                    ),
                    IconButton(onPressed: () => app.remove(e.key), icon: const Icon(Icons.delete_outline, color: Colors.red)),
                  ])),
                ),
              const Totals(),
              FilledButton(onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const CheckoutPage())), child: const Text('إتمام الطلب')),
            ]),
          );
        },
      );
}

// ---------- إتمام الطلب ----------
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckoutPage> {
  final f = GlobalKey<FormState>();
  late final n = TextEditingController(text: app.user?['guest'] == true ? '' : (app.user?['name'] as String? ?? ''));
  late final ph = TextEditingController(text: app.user?['phone'] as String? ?? '');
  final ad = TextEditingController(), nt = TextEditingController(), ref = TextEditingController();
  String pay = 'cod';

  Widget opt(String k, String title, String sub) {
    final sel = pay == k, pr = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => setState(() => pay = k),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: sel ? pr : Theme.of(context).dividerColor, width: sel ? 2 : 1)),
        child: Row(children: [
          Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off, color: pr),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor))])),
        ]),
      ),
    );
  }

  void submit() {
    if (!f.currentState!.validate()) return;
    final o = app.place(name: n.text.trim(), phone: ph.text.trim(), addr: ad.text.trim(), note: nt.text.trim(), pay: pay, ref: pay == 'cod' ? '' : ref.text.trim());
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => DonePage(o)), (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('إتمام الطلب')),
        body: app.cart.isEmpty
            ? const Center(child: Text('السلة فاضية'))
            : Form(
                key: f,
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  const Text('بيانات التوصيل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextFormField(controller: n, decoration: const InputDecoration(labelText: 'الاسم'), validator: (v) => (v ?? '').trim().length < 3 ? 'اكتب اسمك' : null),
                  const SizedBox(height: 10),
                  TextFormField(controller: ph, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الموبايل'), validator: (v) => RegExp(r'^01[0125]\d{8}$').hasMatch((v ?? '').trim()) ? null : 'اكتب رقم موبايل مصري صحيح من 11 رقم'),
                  const SizedBox(height: 10),
                  TextFormField(controller: ad, maxLines: 2, decoration: const InputDecoration(labelText: 'العنوان بالتفصيل', hintText: 'المحافظة، المنطقة، الشارع، رقم العمارة'), validator: (v) => (v ?? '').trim().length < 10 ? 'اكتب العنوان بالتفصيل عشان المندوب يوصلك' : null),
                  const SizedBox(height: 10),
                  TextFormField(controller: nt, maxLines: 2, decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)')),
                  const SizedBox(height: 18),
                  const Text('طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  opt('cod', 'الدفع عند الاستلام', 'ادفع كاش للمندوب وقت التوصيل'),
                  opt('vc', 'فودافون كاش', 'حوّل على $kVcash واكتب رقم العملية'),
                  if (pay == 'vc') ...[
                    const SizedBox(height: 10),
                    TextFormField(controller: ref, decoration: const InputDecoration(labelText: 'رقم عملية التحويل'), validator: (v) => (v ?? '').trim().length < 4 ? 'اكتب رقم عملية التحويل' : null),
                  ],
                  const SizedBox(height: 16),
                  const Totals(),
                  FilledButton(onPressed: submit, child: const Text('تأكيد الطلب')),
                ]),
              ),
      );
}

class DonePage extends StatelessWidget {
  final Map<String, dynamic> o;
  const DonePage(this.o, {super.key});
  @override
  Widget build(BuildContext c) {
    final text = app.orderText(o);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Icon(Icons.check_circle, size: 84, color: Color(0xFF2E9E6B)),
            const SizedBox(height: 12),
            const Text('تم تسجيل طلبك', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('رقم الطلب ${o['id']} · الإجمالي ${o['total']} ج', textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('ابعت الطلب للمحل على واتساب علشان يبدأوا تجهيزه.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(c).hintColor)),
            const SizedBox(height: 24),
            FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white), onPressed: () => openLink(c, waUri(text)), icon: const Icon(Icons.chat), label: const Text('إرسال الطلب على واتساب')),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: () => copyText(c, text), icon: const Icon(Icons.copy), label: const Text('نسخ نص الطلب')),
            TextButton(onPressed: () => Navigator.popUntil(c, (r) => r.isFirst), child: const Text('رجوع للرئيسية')),
          ]),
        ),
      ),
    );
  }
}

// ---------- طلباتي ----------
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (c, _) {
          if (app.orders.isEmpty) return const Center(child: Text('📦\nلسه مفيش طلبات\nطلباتك هتظهر هنا بعد أول عملية شراء.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.8)));
          return SafeArea(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              const Text('طلباتي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for (final o in app.orders)
                Box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text('#${o['id']}', style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Chip(label: Text(o['status'], style: const TextStyle(fontSize: 12)), visualDensity: VisualDensity.compact)]),
                  Text('${o['date']} · ${payName(o['pay'])}', style: TextStyle(fontSize: 12, color: Theme.of(c).hintColor)),
                  const SizedBox(height: 6),
                  Text((o['items'] as List).map((i) => '${i['n']} ${wl(i['g'] as int)}').join('، ')),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('${o['total']} ج', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    TextButton.icon(onPressed: () => openLink(c, waUri(app.orderText(o))), icon: const Icon(Icons.chat, size: 18), label: const Text('واتساب')),
                    TextButton.icon(onPressed: () => copyText(c, app.orderText(o)), icon: const Icon(Icons.copy, size: 18), label: const Text('نسخ')),
                  ]),
                ])),
            ]),
          );
        },
      );
}

// ---------- حسابي ----------
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (c, _) {
          final u = app.user ?? {}, guest = u['guest'] == true;
          return SafeArea(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              const Text('حسابي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Box(Row(children: [
                CircleAvatar(radius: 26, backgroundColor: Theme.of(c).colorScheme.primary, child: Text(((u['name'] as String?) ?? 'ز').characters.first, style: const TextStyle(fontSize: 22, color: Colors.white))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${u['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), Text(guest ? 'تصفح كزائر' : '${u['phone']}')]),
              ])),
              Box(ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.support_agent), title: const Text('تواصل مع المحل'), subtitle: const Text(kTel), onTap: () => showContact(c))),
              const Box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('طرق الدفع', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('الدفع عند الاستلام، أو تحويل فودافون كاش على $kVcash')])),
              OutlinedButton(onPressed: app.logout, child: Text(guest ? 'تسجيل الدخول' : 'تسجيل الخروج')),
            ]),
          );
        },
      );
}
