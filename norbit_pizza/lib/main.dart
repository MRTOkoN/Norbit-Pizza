import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class CategoryChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const CategoryChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.selected
        ? Colors.black
        : (_hover ? Colors.grey.shade300 : Colors.grey.shade200);
    final textColor = widget.selected ? Colors.white : Colors.black87;
    final scale = widget.selected ? 1.0 : (_hover ? 1.04 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..scale(scale, scale),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, String> item;
  final void Function(BuildContext)? onAdd;
  const ProductCard({super.key, required this.item, this.onAdd});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Image.asset(
                  widget.item['image']!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.local_pizza, size: 48, color: Colors.deepPurple)),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(widget.item['title']!, style: const TextStyle(fontWeight: FontWeight.w700))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(widget.item['category']!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.item['desc']!,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.2),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(widget.item['price']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(widget.item['size']!, style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Builder(builder: (btnCtx) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => widget.onAdd?.call(btnCtx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: const [
                                Icon(Icons.shopping_cart, color: Colors.white),
                                SizedBox(width: 10),
                                Text('В корзину', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'НОРБИТ pizza',
      theme: ThemeData(
        fontFamily: 'Norbit',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int _counter = 0;
  final GlobalKey _menuKey = GlobalKey();
  int _selectedCategory = 0;
  String _searchQuery = '';
  final List<String> _categories = ['Все', 'Классические', 'Вегетарианские', 'Мясные', 'Премиум'];
  final List<Map<String, String>> _menuItems = [
    {
      'title': 'Маргарита',
      'desc': 'Томатный соус, моцарелла, базилик',
      'ingredients': 'томатный соус, моцарелла, базилик',
      'price': '499 ₽',
      'size': '30 см',
      'category': 'Классические',
      'image': 'assets/images/pizza1.png'
    },
    {
      'title': 'Пепперони',
      'desc': 'Пепперони, моцарелла, томаты',
      'ingredients': 'пепперони, моцарелла, томаты, орегано',
      'price': '599 ₽',
      'size': '32 см',
      'category': 'Мясные',
      'image': 'assets/images/pizza2.png'
    },
    {
      'title': 'Вегги',
      'desc': 'Овощи гриль, моцарелла, руккола',
      'ingredients': 'баклажан, цуккини, перец, моцарелла, руккола',
      'price': '549 ₽',
      'size': '30 см',
      'category': 'Вегетарианские',
      'image': 'assets/images/pizza3.png'
    },
    {
      'title': '4 Сыра',
      'desc': 'Моцарелла, пармезан, горгонзола, эмменталь',
      'ingredients': 'моцарелла, пармезан, горгонзола, эмменталь',
      'price': '699 ₽',
      'size': '33 см',
      'category': 'Премиум',
      'image': 'assets/images/pizza4.png'
    },
  ];

  // Cart state
  final List<Map<String, dynamic>> _cartItems = [];
  bool _isCartOpen = false;
  final GlobalKey _cartIconKey = GlobalKey();

  void _toggleCart([bool? open]) {
    setState(() => _isCartOpen = open ?? !_isCartOpen);
  }

  void _addToCart(Map<String, String> item) {
    setState(() {
      final idx = _cartItems.indexWhere((c) => c['title'] == item['title'] && c['size'] == item['size']);
      if (idx >= 0) {
        _cartItems[idx]['qty'] = (_cartItems[idx]['qty'] as int) + 1;
      } else {
        _cartItems.add({
          'title': item['title'],
          'price': item['price'],
          'size': item['size'],
          'image': item['image'],
          'category': item['category'],
          'qty': 1,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Добавлено: ${item['title']}')));
  }

  int _cartCount() {
    var c = 0;
    for (final it in _cartItems) {
      c += (it['qty'] as int);
    }
    return c;
  }

  String _itemTotal(Map<String, dynamic> it) {
    final priceStr = (it['price'] ?? '') as String;
    final digits = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    final p = int.tryParse(digits) ?? 0;
    final total = p * (it['qty'] as int);
    return '$total ₽';
  }

  Future<void> _runAddWithAnimation(BuildContext sourceContext, Map<String, String> item) async {
    final overlay = Overlay.of(context);
    if (overlay == null) {
      _addToCart(item);
      return;
    }

    final renderBoxSrc = sourceContext.findRenderObject() as RenderBox?;
    final renderBoxDst = _cartIconKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBoxSrc == null) {
      _addToCart(item);
      return;
    }

    final srcSize = renderBoxSrc.size;
    final srcPos = renderBoxSrc.localToGlobal(Offset.zero);
    final start = Offset(srcPos.dx + srcSize.width / 2 - 32, srcPos.dy + srcSize.height / 2 - 32);

    Offset end;
    if (renderBoxDst != null) {
      final dstPos = renderBoxDst.localToGlobal(Offset.zero);
      final dstSize = renderBoxDst.size;
      end = Offset(dstPos.dx + dstSize.width / 2 - 16, dstPos.dy + dstSize.height / 2 - 16);
    } else {
      final sw = MediaQuery.of(context).size.width;
      end = Offset(sw - 40, 24);
    }

    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    final overlayEntry = OverlayEntry(builder: (ctx) {
      return AnimatedBuilder(
        animation: animation,
        builder: (ctx, child) {
          final t = animation.value;
          final x = lerpDouble(start.dx, end.dx, t)!;
          final y = lerpDouble(start.dy, end.dy, t)!;
          double scale;
          if (t < 0.4) {
            scale = lerpDouble(1.0, 1.4, t / 0.4)!;
          } else {
            scale = lerpDouble(1.4, 0.28, (t - 0.4) / 0.6)!;
          }
          final rot = lerpDouble(0, 2.0, t)! * 0.8; // small rotation

          return Positioned(
            left: x,
            top: y,
            child: Transform.rotate(
              angle: rot,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            ),
          );
        },
        child: SizedBox(
          width: 64,
          height: 64,
          child: Image.asset(item['image']!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.local_pizza))),
        ),
      );
    });

    overlay.insert(overlayEntry);
    try {
      await controller.forward();
    } catch (_) {}
    overlayEntry.remove();
    controller.dispose();

    _addToCart(item);
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _changeQty(int index, int delta) {
    setState(() {
      final current = _cartItems[index]['qty'] as int;
      final updated = (current + delta).clamp(1, 999);
      _cartItems[index]['qty'] = updated;
    });
  }

  String _cartTotal() {
    int sum = 0;
    for (final it in _cartItems) {
      final priceStr = (it['price'] ?? '') as String;
      final digits = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
      final p = int.tryParse(digits) ?? 0;
      sum += p * (it['qty'] as int);
    }
    return '$sum ₽';
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _scrollToMenu() {
    final context = _menuKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void _showProductDetail(Map<String, String> item) {
    final ingredients = (item['ingredients'] ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    showDialog(
      context: context,
      builder: (dialogContext) {
        final sw = MediaQuery.of(dialogContext).size.width;
        final sh = MediaQuery.of(dialogContext).size.height;
        final dialogWidth = sw > 900 ? 900.0 : sw * 0.95;
        final dialogHeight = sh * 0.8;

        final isVertical = dialogWidth < 600 || sw < 500;
        // Increase minimum scale so fonts don't get too small on narrow devices
        final scale = (dialogWidth / 900.0).clamp(0.75, 1.0);
        final scrollController = ScrollController();
        final titleSize = 20.0 * scale;
        final descSize = 14.0 * scale;
        final chipFont = 14.0 * scale;
        final buttonFont = 16.0 * scale;

        if (isVertical) {
          // Stack image on top for narrow screens
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: dialogHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image on top
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    child: Image.asset(
                      item['image']!,
                      width: double.infinity,
                      height: dialogHeight * 0.38,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.local_pizza, size: 48, color: Colors.deepPurple)),
                    ),
                  ),
                  // Details (scrollable)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'] ?? '', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                child: Text(item['category'] ?? '', style: TextStyle(fontSize: (chipFont - 2), fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(item['desc'] ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: descSize)),
                            const SizedBox(height: 12),
                            Text('Ингредиенты', style: TextStyle(fontWeight: FontWeight.w600, fontSize: chipFont)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ingredients.map((ing) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Text(ing, style: TextStyle(color: Colors.black87, fontSize: chipFont - 2)),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: Text('Размер', style: TextStyle(color: Colors.grey.shade600, fontSize: descSize - 2))),
                                Expanded(child: Align(alignment: Alignment.centerRight, child: Text('Цена', style: TextStyle(color: Colors.grey.shade600, fontSize: descSize - 2)))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(child: Text(item['size'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: descSize))),
                                Expanded(child: Align(alignment: Alignment.centerRight, child: Text(item['price'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: descSize)))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Builder(builder: (btnCtx) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await _runAddWithAnimation(btnCtx, item);
                                    Navigator.of(dialogContext).pop();
                                  },
                                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                                  label: Text('Добавить в корзину за ${item['price'] ?? ''}', style: TextStyle(color: Colors.white, fontSize: buttonFont)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: EdgeInsets.symmetric(vertical: 12 * scale)),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text('ℹ️ Все пиццы готовятся из свежих ингредиентов в дровяной печи. Среднее время приготовления: 15-20 минут.', style: TextStyle(color: Colors.grey.shade600, fontSize: descSize - 2)),
                          ],
                        ),
                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Horizontal / default layout
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: dialogHeight),
            child: Row(
              children: [
                // Left: image full height
                Flexible(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                    child: Image.asset(
                      item['image']!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.local_pizza, size: 48, color: Colors.deepPurple)),
                    ),
                  ),
                ),
                // Right: details
                Flexible(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(item['title'] ?? '', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w700)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                child: Text(item['category'] ?? '', style: TextStyle(fontSize: chipFont - 2, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(item['desc'] ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: descSize)),
                          const SizedBox(height: 16),
                          Text('Ингредиенты', style: TextStyle(fontWeight: FontWeight.w600, fontSize: chipFont)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ingredients.map((ing) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                child: Text(ing, style: TextStyle(color: Colors.black87, fontSize: chipFont - 2)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // Labels (grey)
                          Row(
                            children: [
                              Expanded(child: Text('Размер', style: TextStyle(color: Colors.grey.shade600, fontSize: descSize - 2))),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: Text('Цена', style: TextStyle(color: Colors.grey.shade600, fontSize: descSize - 2)))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Values (black)
                          Row(
                            children: [
                              Expanded(child: Text(item['size'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: descSize))),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: Text(item['price'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: descSize)))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Builder(builder: (btnCtx) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await _runAddWithAnimation(btnCtx, item);
                                  Navigator.of(dialogContext).pop();
                                },
                                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                                label: Text('Добавить в корзину за ${item['price'] ?? ''}', style: TextStyle(color: Colors.white, fontSize: buttonFont)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: EdgeInsets.symmetric(vertical: 12 * scale)),
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('ℹ️ Все пиццы готовятся из свежих ингредиентов в дровяной печи. Среднее время приготовления: 15-20 минут.', style: TextStyle(color: Colors.grey.shade600, fontSize: descSize - 2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final panelWidth = sw > 600 ? 420.0 : sw * 0.85;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: SafeArea(
          child: Material(
            elevation: 6,
            color: Colors.black,
            child: Container(
              width: double.infinity,
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Логотип
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.local_pizza, size: 32, color: Colors.deepPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Шапка сайта
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'НОРБИТ pizza',
                            style: TextStyle(
                              fontFamily: 'Norbit',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'сеть №1 в России по вкусу пиццы',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Cart button (top-right) with badge
                  // Cart button (top-right) with badge
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: SizedBox(
                      key: _cartIconKey,
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            onPressed: _toggleCart,
                            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                            tooltip: 'Открыть корзину',
                          ),
                          if (_cartCount() > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                child: Center(
                                  child: Text('${_cartCount()}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 90),

            // Инфо-баннер
            LayoutBuilder(builder: (context, bannerConstraints) {
              final bw = bannerConstraints.maxWidth;
              final double bannerHeight = bw > 1000 ? 520 : (bw > 700 ? 420 : 300);
              final double fontSize = (bw * 0.028).clamp(14.0, 22.0).toDouble();

              return SizedBox(
                width: double.infinity,
                height: bannerHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/banner.png',
                      width: double.infinity,
                      height: bannerHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(child: Icon(Icons.photo, size: 64, color: Colors.grey)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.45), Colors.black.withOpacity(0.15)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: bw > 500 ? 24 : 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Настоящая итальянская пицца\n\nПриготовлена с любовью из свежих ингредиентов\n\nКаждая пицца - это маленькое произведение искусства, созданное нашими опытными пиццайоло по традиционным итальянским рецептам',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: fontSize, height: 1.35, fontWeight: FontWeight.w300),
                            ),
                            SizedBox(height: bw > 500 ? 18 : 12),
                            ElevatedButton.icon(
                              onPressed: _scrollToMenu,
                              icon: const Icon(Icons.arrow_downward, color: Colors.white),
                              label: const Text('Посмотреть меню', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Меню
            Padding(
              key: _menuKey,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Наше меню', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Выберите свою любимую пиццу из нашего разнообразного меню', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 32),

                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Поиск пиццы',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 8),

                  // Категории товаров
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_categories.length, (index) {
                      final selected = _selectedCategory == index;
                      return CategoryChip(
                        label: _categories[index],
                        selected: selected,
                        onTap: () => setState(() => _selectedCategory = index),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),

                  // Сетка товаров
                  LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final cross = width > 1000 ? 3 : (width > 600 ? 2 : 1);
                    final displayed = _menuItems.where((it) {
                      final byCategory = _selectedCategory == 0 || it['category'] == _categories[_selectedCategory];
                      final bySearch = _searchQuery.isEmpty || it['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) || it['desc']!.toLowerCase().contains(_searchQuery.toLowerCase());
                      return byCategory && bySearch;
                    }).toList();

                    return GridView.builder(
                      itemCount: displayed.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final item = displayed[index];
                        return GestureDetector(
                          onTap: () => _showProductDetail(item),
                          child: ProductCard(item: item, onAdd: (btnCtx) => _runAddWithAnimation(btnCtx, item)),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      // Backdrop (dim) when cart is open
      if (_isCartOpen)
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _toggleCart(false),
            child: Container(
              color: Colors.black54,
            ),
          ),
        ),

      // Slide-in cart panel
      AnimatedPositioned(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        top: 0,
        bottom: 0,
        right: _isCartOpen ? 0 : -panelWidth,
        width: panelWidth,
        child: Material(
          elevation: 12,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Корзина', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                      IconButton(
                        onPressed: () => _toggleCart(false),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Colors.grey),

                // Cart items list
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(child: Text('Корзина пуста', style: TextStyle(color: Colors.black54)))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          itemCount: _cartItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final it = _cartItems[index];
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image square
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      it['image'] ?? '',
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(width: 72, height: 72, color: Colors.grey.shade200, child: const Icon(Icons.local_pizza, color: Colors.deepPurple)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: Text('${it['title']}', style: const TextStyle(fontWeight: FontWeight.w700))),
                                            Text(_itemTotal(it), style: const TextStyle(fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text('${it['size']}', style: TextStyle(color: Colors.grey.shade600)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            // Quantity controls
                                            Container(
                                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () => _changeQty(index, -1),
                                                    icon: const Icon(Icons.remove, size: 18),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Text('${(it['qty'] as int)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                                  ),
                                                  IconButton(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () => _changeQty(index, 1),
                                                    icon: const Icon(Icons.add, size: 18),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            // Delete button with extra right padding
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: IconButton(
                                                onPressed: () => _removeFromCart(index),
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Bottom bar with total and checkout
                const Divider(height: 1, color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text('Итого:', style: TextStyle(fontWeight: FontWeight.w700))),
                          Text(_cartTotal(), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _cartItems.isEmpty ? null : () {},
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                          child: const Text('Оформить заказ', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ), // end Column
          ), // end SafeArea
        ), // end Material
      ), // end AnimatedPositioned
      ], // end Stack children
    ), // end Stack
  );
  }
}
