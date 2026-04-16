import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/network_or_base64_image.dart';

class TipDetailScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String content;
  final String readTime;

  const TipDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
    this.readTime = '5 мин',
  });

  static List<Map<String, String>> getTips(String langCode) {
    switch (langCode) {
      case 'kk':
        return [
          {
            'title': 'Котенканы лотокқа қалай үйрету керек?',
            'image':
                'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
            'readTime': '5 мин',
            'content':
                '''🐱 Котенканы лотокқа үйрету — сабырлылық пен дұрыс әдістерді қажет ететін процесс.

📍 Лотокты дұрыс орнатыңыз
Лотокты тыныш, қол жетімді жерге қойыңыз. Тамақтанатын жерден алыс болсын. Мысық жеке кеңістікті ұнатады.

🕐 Тамақтанғаннан кейін лотокқа апарыңыз
Котенка тамақтанғаннан 15-20 минут кейін лотокқа отырғызыңыз. Бұл табиғи рефлексті дамытады.

✅ Дұрыс толтырғыш таңдаңыз
Жұмсақ, иіссіз толтырғышты таңдаңыз. Котенкалар жұмсақ текстураны жақсы көреді.

🎉 Сәтті әрекетті мадақтаңыз
Лотокты дұрыс пайдаланған кезде котенканы сипаңыз және мақтаңыз. Тағамдық сыйлық беруге болады.

⚠️ Жазаламаңыз!
Егер котенка дұрыс емес жерге барса, жазаламаңыз. Бұл қорқыныш тудырады. Тек тазалаңыз және сабырмен қайталаңыз.

💡 Кеңес: Бірнеше лоток қойыңыз — мысықтар саны + 1 формуласын қолданыңыз.''',
          },
          {
            'title': 'Иттерге арналған дұрыс тамақтану',
            'image':
                'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=800&q=80',
            'readTime': '7 мин',
            'content': '''🐕 Итіңіздің денсаулығы дұрыс тамақтанудан басталады.

🥩 Негізгі қоректік заттар
Иттерге ақуыз (ет, балық), көмірсулар (күріш, көкөністер), майлар (балық майы) қажет.

📏 Порция мөлшері
- Шағын тұқымдар: дене салмағының 3-4%
- Орта тұқымдар: 2-3%
- Ірі тұқымдар: 1.5-2%

⏰ Тамақтану кестесі
Күніне 2 рет (ересек иттер) немесе 3-4 рет (күшіктер) тамақтандырыңыз. Тұрақты уақытта беріңіз.

🚫 Берілмейтін тағамдар
- Шоколад (улы!)
- Жүзім мен жүзімнің кептірілгені
- Пияз бен сарымсақ
- Сүйектер (әсіресе тауық сүйектері)

💊 Витаминдер
Ветеринарға кеңесіңіз. Таза тамақпен тамақтандырсаңыз, витамин қосымшалары қажет болуы мүмкін.

💡 Маңызды: Таза су әрқашан қол жетімді болсын!''',
          },
          {
            'title': 'Жүнге күтім жасау',
            'image':
                'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=800&q=80',
            'readTime': '4 мин',
            'content':
                '''✨ Жүнге дұрыс күтім — сіздің питомцыңыздың сұлулығы мен денсаулығының кілті.

🪮 Тарау жиілігі
- Ұзын жүнді: күнделікті
- Орта жүнді: аптасына 2-3 рет
- Қысқа жүнді: аптасына 1 рет

🛁 Шомылдыру
Иттерді айына 1-2 рет шомылдырыңыз. Мысықтар өздері тазаланады, бірақ кейде көмек қажет.

🧴 Дұрыс шампунь
Адамның шампунін ҚОЛДАНБАҢЫЗ! Жануарларға арналған pH-балансталған шампунь қолданыңыз.

💇 Кәсіби груминг
3-4 айда бір рет грумерге апарыңыз. Олар тырнақ кесу, құлақ тазалау және арнайы стрижка жасайды.

🍎 Тамақтану
Омега-3 және Омега-6 қышқылдары бар тамақ жүнді жылтыратады. Балық майын қосуға болады.

💡 Кеңес: Жүн түсу маусым кезінде (көктем/күз) тарауды жиілетіңіз.''',
          },
        ];
      case 'en':
        return [
          {
            'title': 'How to litter train a kitten?',
            'image':
                'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
            'readTime': '5 min',
            'content':
                '''🐱 Litter training a kitten requires patience and the right approach.

📍 Place the litter box correctly
Put it in a quiet, accessible area away from food. Cats prefer private spaces.

🕐 Take kitten to the box after meals
15-20 minutes after eating, place your kitten in the litter box. This develops natural reflexes.

✅ Choose the right litter
Select soft, unscented litter. Kittens prefer soft textures for digging.

🎉 Reward success
When they use the box correctly, pet and praise them. You can give a small treat.

⚠️ Never punish!
If they have an accident, don't punish. It causes fear. Just clean up and try again patiently.

💡 Tip: Have multiple litter boxes — use the formula: number of cats + 1.''',
          },
          {
            'title': 'Proper diet for dogs',
            'image':
                'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=800&q=80',
            'readTime': '7 min',
            'content': '''🐕 Your dog's health starts with proper nutrition.

🥩 Essential nutrients
Dogs need protein (meat, fish), carbohydrates (rice, vegetables), and fats (fish oil).

📏 Portion sizes
- Small breeds: 3-4% of body weight
- Medium breeds: 2-3%
- Large breeds: 1.5-2%

⏰ Feeding schedule
Feed 2 times a day (adult dogs) or 3-4 times (puppies). Keep consistent timing.

🚫 Foods to avoid
- Chocolate (toxic!)
- Grapes and raisins
- Onions and garlic
- Cooked bones (especially chicken)

💊 Supplements
Consult your vet. Raw-fed dogs may need vitamin supplements.

💡 Important: Fresh water should always be available!''',
          },
          {
            'title': 'Coat care tips',
            'image':
                'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=800&q=80',
            'readTime': '4 min',
            'content':
                '''✨ Proper coat care is key to your pet's beauty and health.

🪮 Brushing frequency
- Long coat: daily
- Medium coat: 2-3 times per week
- Short coat: once a week

🛁 Bathing
Bathe dogs 1-2 times per month. Cats groom themselves but sometimes need help.

🧴 Right shampoo
NEVER use human shampoo! Use pH-balanced pet shampoo.

💇 Professional grooming
Visit a groomer every 3-4 months for nail trimming, ear cleaning, and specialized cuts.

🍎 Nutrition
Food with Omega-3 and Omega-6 fatty acids makes coats shiny. Consider adding fish oil.

💡 Tip: Increase brushing during shedding season (spring/fall).''',
          },
        ];
      default: // ru
        return [
          {
            'title': 'Как приучить котенка к лотку?',
            'image':
                'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
            'readTime': '5 мин',
            'content':
                '''🐱 Приучение котенка к лотку — процесс, требующий терпения и правильного подхода.

📍 Правильно расположите лоток
Поставьте лоток в тихое, доступное место, подальше от еды. Кошки предпочитают уединённые места.

🕐 После еды — в лоток
Через 15-20 минут после приёма пищи посадите котенка в лоток. Это формирует естественный рефлекс.

✅ Выберите правильный наполнитель
Выбирайте мягкий наполнитель без запаха. Котята предпочитают мягкую текстуру для копания.

🎉 Поощряйте успехи
Когда котенок правильно использует лоток, погладьте и похвалите его. Можно дать маленькое лакомство.

⚠️ Никогда не наказывайте!
Если котенок сходил мимо, не наказывайте — это вызывает страх. Просто уберите и терпеливо повторяйте.

💡 Совет: Поставьте несколько лотков — используйте формулу: количество кошек + 1.''',
          },
          {
            'title': 'Правильный рацион для собак',
            'image':
                'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=800&q=80',
            'readTime': '7 мин',
            'content':
                '''🐕 Здоровье вашей собаки начинается с правильного питания.

🥩 Основные питательные вещества
Собакам нужны белки (мясо, рыба), углеводы (рис, овощи) и жиры (рыбий жир).

📏 Размер порций
- Мелкие породы: 3-4% от массы тела
- Средние породы: 2-3%
- Крупные породы: 1.5-2%

⏰ График кормления
Кормите 2 раза в день (взрослые) или 3-4 раза (щенки). Соблюдайте постоянное время.

🚫 Запрещённые продукты
- Шоколад (токсичен!)
- Виноград и изюм
- Лук и чеснок
- Варёные кости (особенно куриные)

💊 Витамины
Проконсультируйтесь с ветеринаром. При натуральном питании могут потребоваться добавки.

💡 Важно: Чистая вода должна быть доступна всегда!''',
          },
          {
            'title': 'Уход за шерстью',
            'image':
                'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=800&q=80',
            'readTime': '4 мин',
            'content':
                '''✨ Правильный уход за шерстью — залог красоты и здоровья вашего питомца.

🪮 Частота расчёсывания
- Длинная шерсть: ежедневно
- Средняя шерсть: 2-3 раза в неделю
- Короткая шерсть: раз в неделю

🛁 Купание
Собак купайте 1-2 раза в месяц. Кошки моются сами, но иногда нужна помощь.

🧴 Правильный шампунь
НЕ используйте человеческий шампунь! Берите специальный pH-сбалансированный для животных.

💇 Профессиональный груминг
Раз в 3-4 месяца водите к грумеру — подстригут когти, почистят уши, сделают стрижку.

🍎 Питание
Корм с Омега-3 и Омега-6 делает шерсть блестящей. Можно добавлять рыбий жир.

💡 Совет: Во время линьки (весна/осень) расчёсывайте чаще.''',
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkOrBase64Image(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: Container(color: Colors.grey[300]),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                readTime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              transform: Matrix4.translationValues(0.0, -24.0, 0.0),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      AppTheme.textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
