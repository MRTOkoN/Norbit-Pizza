import 'package:flutter/material.dart';
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
  const ProductCard({super.key, required this.item});

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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                      ),
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

class _MyHomePageState extends State<MyHomePage> {
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
                                child: Text(item['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                child: Text(item['category'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(item['desc'] ?? '', style: TextStyle(color: Colors.grey.shade700)),
                          const SizedBox(height: 16),
                          const Text('Ингредиенты', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ingredients.map((ing) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                child: Text(ing, style: const TextStyle(color: Colors.black87)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // Labels (grey)
                          Row(
                            children: [
                              Expanded(child: Text('Размер', style: TextStyle(color: Colors.grey.shade600))),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: Text('Цена', style: TextStyle(color: Colors.grey.shade600)))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Values (black)
                          Row(
                            children: [
                              Expanded(child: Text(item['size'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black))),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: Text(item['price'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Добавлено: ${item['title']}')));
                              },
                              icon: const Icon(Icons.shopping_cart, color: Colors.white),
                              label: Text('Добавить в корзину за ${item['price'] ?? ''}', style: const TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('ℹ️ Все пиццы готовятся из свежих ингредиентов в дровяной печи. Среднее время приготовления: 15-20 минут.', style: TextStyle(color: Colors.grey.shade600)),
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
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                          child: ProductCard(item: item),
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
    );
  }
}
