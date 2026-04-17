import 'package:flutter/material.dart';

class FunFactsScreen extends StatefulWidget {
  final String locationName;
  final String category;
  final List<Color> gradientColors;

  const FunFactsScreen({
    super.key,
    required this.locationName,
    required this.category,
    required this.gradientColors,
  });

  @override
  State<FunFactsScreen> createState() => _FunFactsScreenState();
}

class _FunFactsScreenState extends State<FunFactsScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  List<_Fact> get _facts =>
      _locationFacts[widget.locationName] ??
      _categoryFacts[widget.category] ??
      _defaultFacts;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facts = _facts;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1825),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: facts.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _buildCard(facts[i], i, facts.length),
                  ),
                ),
                _buildDots(facts.length),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fun Facts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.locationName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const Text('✨', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Fact card ─────────────────────────────────────────────────────────────

  Widget _buildCard(_Fact fact, int index, int total) {
    final baseColor = widget.gradientColors.last;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF162030),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: baseColor.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            // Fact counter
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Fact ${index + 1} of $total',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(height: 28),
            // Emoji
            Text(fact.emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                fact.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                fact.body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  height: 1.65,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Swipe hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_rounded,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.25)),
                const SizedBox(width: 6),
                Text(
                  'Swipe for more facts',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Dots indicator ────────────────────────────────────────────────────────

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentPage ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentPage
                ? const Color(0xFF00C2CC)
                : const Color(0xFF374151),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _Fact {
  final String emoji;
  final String title;
  final String body;
  const _Fact({required this.emoji, required this.title, required this.body});
}

const _locationFacts = <String, List<_Fact>>{
  'Labadi Beach': [
    _Fact(
      emoji: '🌊',
      title: 'Atlantic Coastline',
      body:
          'Labadi Beach sits on the Gulf of Guinea, part of the Atlantic Ocean. It stretches over 2 km and is the most visited beach in Accra.',
    ),
    _Fact(
      emoji: '🎵',
      title: 'Festival Hub',
      body:
          'Labadi hosts the annual Chale Wote Street Art Festival — one of West Africa\'s biggest street art events, drawing thousands of visitors each August.',
    ),
    _Fact(
      emoji: '🐢',
      title: 'Marine Life',
      body:
          'The waters off Labadi are home to several tropical fish species and sea turtles that occasionally nest along Ghana\'s coastline.',
    ),
  ],
  'GameZone Osu': [
    _Fact(
      emoji: '🕹️',
      title: 'Gaming Capital',
      body:
          'GameZone is one of Ghana\'s biggest entertainment arcades, featuring retro classics and modern gaming experiences loved by all ages.',
    ),
    _Fact(
      emoji: '🏙️',
      title: 'Osu\'s Heritage',
      body:
          'Osu (originally "Christiansborg") has been Accra\'s commercial hub since the 17th century, when Danish merchants settled along its coast.',
    ),
    _Fact(
      emoji: '💰',
      title: 'Billion-Dollar Industry',
      body:
          'The global gaming industry is worth over \$200 billion — larger than the movie and music industries combined.',
    ),
  ],
  'Aburi Botanical Garden': [
    _Fact(
      emoji: '🌿',
      title: 'Est. 1890',
      body:
          'The Aburi Botanical Gardens were founded by the British colonial government as a tropical plant research station — making them over 130 years old.',
    ),
    _Fact(
      emoji: '🌳',
      title: 'Rich Biodiversity',
      body:
          'The gardens span 64 hectares and contain over 1,600 plant species, including rare tropical trees more than a century old.',
    ),
    _Fact(
      emoji: '🏔️',
      title: 'Cool Highlands',
      body:
          'Aburi sits 400 m above sea level in the Akuapem-Togo Range, making it noticeably cooler than Accra — typically 5 °C lower on a hot day.',
    ),
  ],
  'Aburi Botanical Gardens': [
    _Fact(
      emoji: '🌿',
      title: 'Est. 1890',
      body:
          'The Aburi Botanical Gardens were founded by the British colonial government as a tropical plant research station — making them over 130 years old.',
    ),
    _Fact(
      emoji: '🌳',
      title: 'Rich Biodiversity',
      body:
          'The gardens span 64 hectares and contain over 1,600 plant species, including rare tropical trees more than a century old.',
    ),
    _Fact(
      emoji: '🏔️',
      title: 'Cool Highlands',
      body:
          'Aburi sits 400 m above sea level in the Akuapem-Togo Range, making it noticeably cooler than Accra — typically 5 °C lower on a hot day.',
    ),
  ],
  'Santoku Restaurant': [
    _Fact(
      emoji: '🍣',
      title: 'The Name',
      body:
          '"Santoku" (三徳) means "three virtues" in Japanese. It\'s also the name of Japan\'s most popular all-purpose kitchen knife.',
    ),
    _Fact(
      emoji: '🍜',
      title: 'Umami Discovered',
      body:
          'Japanese cuisine introduced the world to umami — the fifth basic taste alongside sweet, sour, bitter, and salty — identified by Professor Kikunae Ikeda in 1908.',
    ),
    _Fact(
      emoji: '⭐',
      title: 'Michelin Star Capital',
      body:
          'Tokyo has more Michelin-starred restaurants than any other city in the world — more than Paris and New York combined.',
    ),
  ],
  'National Museum of Ghana': [
    _Fact(
      emoji: '🏛️',
      title: 'Class of \'57',
      body:
          'The National Museum of Ghana opened in 1957, the same year Ghana became the first sub-Saharan African country to gain independence from colonial rule.',
    ),
    _Fact(
      emoji: '👑',
      title: 'Royal Artefacts',
      body:
          'The museum houses hundreds of royal regalia, traditional costumes, and artefacts from the Ashanti, Ga, Ewe, and other Ghanaian ethnic groups.',
    ),
    _Fact(
      emoji: '🎨',
      title: 'Living Heritage',
      body:
          'Collections include kente cloth, brass gold weights, and ancient carved wooden stools — powerful symbols of authority in Ghanaian culture.',
    ),
  ],
  'Accra Mall': [
    _Fact(
      emoji: '🛍️',
      title: 'West Africa Pioneer',
      body:
          'Accra Mall, opened in 2008, was one of West Africa\'s first modern shopping malls — a landmark moment in Ghana\'s retail evolution.',
    ),
    _Fact(
      emoji: '🌍',
      title: 'Local Meets Global',
      body:
          'The mall hosts over 60 local and international retailers, blending Ghanaian brands with global names under one roof.',
    ),
    _Fact(
      emoji: '☀️',
      title: 'Solar Shift',
      body:
          'Many of Accra\'s major commercial buildings are transitioning to solar energy as Ghana accelerates its renewable energy goals.',
    ),
  ],
  'Laboma Beach': [
    _Fact(
      emoji: '🌅',
      title: 'Quiet Coast',
      body:
          'Unlike the lively Labadi, Laboma Beach is quieter and less commercialised — a favourite among locals who want a peaceful day by the sea.',
    ),
    _Fact(
      emoji: '🎣',
      title: 'Fishing Heritage',
      body:
          'Communities near Laboma have fished the Atlantic for generations using traditional wooden canoes, a practice still very much alive today.',
    ),
    _Fact(
      emoji: '🐦',
      title: 'Bird Flyway',
      body:
          'Accra\'s coastline sits along the West African flyway — a migratory route used by thousands of birds traveling between Europe and southern Africa.',
    ),
  ],
  'Mövenpick Ambassador Hotel': [
    _Fact(
      emoji: '🌟',
      title: 'Diplomatic History',
      body:
          'The Mövenpick Ambassador Hotel has hosted heads of state and international delegations since it opened — a cornerstone of Accra\'s luxury hospitality scene.',
    ),
    _Fact(
      emoji: '🏊',
      title: 'Ocean Views',
      body:
          'The hotel features one of Accra\'s most acclaimed rooftop pools, offering panoramic views over the Atlantic Ocean and the city skyline.',
    ),
    _Fact(
      emoji: '🇨🇭',
      title: 'Swiss Legacy',
      body:
          'Mövenpick is a Swiss brand founded in 1948, famous for its premium ice cream and upscale hotels now operating in over 35 countries.',
    ),
  ],
  'Legon Botanical Gardens': [
    _Fact(
      emoji: '🎓',
      title: 'University Legacy',
      body:
          'The Legon Botanical Gardens form part of the University of Ghana campus, founded in the 1950s as a research and conservation facility.',
    ),
    _Fact(
      emoji: '🦋',
      title: 'Biodiversity Hotspot',
      body:
          'The gardens are home to hundreds of butterfly species, reptiles, and over 800 plant species, making them a living laboratory for ecology.',
    ),
    _Fact(
      emoji: '🌱',
      title: 'Conservation Mission',
      body:
          'The gardens actively conserve several native Ghanaian plant species endangered by deforestation and rapid urban expansion.',
    ),
  ],
};

const _categoryFacts = <String, List<_Fact>>{
  'Beach': [
    _Fact(
      emoji: '🌊',
      title: 'Ocean Covers 71%',
      body:
          'The ocean covers 71% of Earth\'s surface and contains 97% of all the water on the planet.',
    ),
    _Fact(
      emoji: '🐠',
      title: 'Marine Diversity',
      body:
          'The ocean is home to over 230,000 known species — and scientists believe up to two million more await discovery in the deep.',
    ),
    _Fact(
      emoji: '🧂',
      title: 'Natural Salt',
      body:
          'If all the salt in the ocean were spread on land, it would form a layer about 166 metres thick — taller than a 50-storey building.',
    ),
  ],
  'Park': [
    _Fact(
      emoji: '🌳',
      title: 'Trees Breathe',
      body:
          'A single mature tree can absorb over 22 kg of CO₂ per year and release enough oxygen for two people to breathe.',
    ),
    _Fact(
      emoji: '🌿',
      title: 'Healing Nature',
      body:
          'Studies show that spending just 20 minutes in a park reduces stress hormones by up to 21% — nature is one of the best medicines.',
    ),
    _Fact(
      emoji: '🦋',
      title: 'Hidden Worlds',
      body:
          'A single square metre of forest floor can contain thousands of invertebrates — insects, worms, and mites all playing vital ecosystem roles.',
    ),
  ],
  'Arcade': [
    _Fact(
      emoji: '🕹️',
      title: 'Gaming History',
      body:
          'The first commercially sold video game was "Computer Space" in 1971. Pong followed in 1972 and became the arcade industry\'s first breakout hit.',
    ),
    _Fact(
      emoji: '💰',
      title: 'Billion-Dollar Industry',
      body:
          'The global gaming industry generates over \$200 billion annually — larger than the movie and music industries combined.',
    ),
    _Fact(
      emoji: '🧠',
      title: 'Brain Boost',
      body:
          'Research shows that action video games improve reaction time, spatial reasoning, and multitasking abilities in players.',
    ),
  ],
  'Museum': [
    _Fact(
      emoji: '🏛️',
      title: 'Ancient Origins',
      body:
          'The world\'s first museum is considered to be the Ennigaldi-Nanna\'s Museum in ancient Ur (modern Iraq), dating to around 530 BC.',
    ),
    _Fact(
      emoji: '🖼️',
      title: 'Most Visited',
      body:
          'The Louvre in Paris is the world\'s most visited museum, welcoming nearly 10 million visitors per year to view over 380,000 objects.',
    ),
    _Fact(
      emoji: '🔍',
      title: 'Hidden Collections',
      body:
          'Most museums display only 2–5% of their collections at any one time. The rest is preserved in climate-controlled storage for future generations.',
    ),
  ],
  'Shopping': [
    _Fact(
      emoji: '🛍️',
      title: 'Global Retail',
      body:
          'The global retail industry is worth over \$27 trillion, with online retail growing to account for more than 20% of all sales.',
    ),
    _Fact(
      emoji: '📦',
      title: 'Supply Chain Marvel',
      body:
          'A typical smartphone travels through up to 37 countries during its supply chain journey before reaching a store shelf.',
    ),
    _Fact(
      emoji: '♻️',
      title: 'Sustainable Shift',
      body:
          'Consumers are increasingly choosing sustainable brands — over 60% of shoppers say environmental impact influences their purchase decisions.',
    ),
  ],
  'Leisure': [
    _Fact(
      emoji: '🏨',
      title: 'Hospitality History',
      body:
          'The modern hotel concept dates to 17th-century England, when "inns" began offering private rooms and meals to travelling merchants.',
    ),
    _Fact(
      emoji: '🌍',
      title: 'Global Tourism',
      body:
          'Tourism is one of the world\'s largest industries, contributing over \$9 trillion to the global economy before the 2020 pandemic.',
    ),
    _Fact(
      emoji: '⭐',
      title: 'Star Ratings',
      body:
          'The five-star hotel rating system was popularised by Mobil (now Forbes) in the 1950s to help American travellers identify premium accommodations.',
    ),
  ],
  'Restaurant': [
    _Fact(
      emoji: '🍽️',
      title: 'First Restaurant',
      body:
          'The word "restaurant" comes from the French "restaurer" (to restore). The first modern restaurant opened in Paris around 1765.',
    ),
    _Fact(
      emoji: '⭐',
      title: 'Michelin Stars',
      body:
          'The Michelin Guide was originally published in 1900 by tyre company Michelin to encourage more road trips — and more tyre wear.',
    ),
    _Fact(
      emoji: '🥢',
      title: 'Global Flavours',
      body:
          'There are over 1 million restaurants in the US alone. Globally, food service generates approximately \$3.5 trillion in revenue each year.',
    ),
  ],
};

const _defaultFacts = <_Fact>[
  _Fact(
    emoji: '🌍',
    title: 'Accra at a Glance',
    body:
        'Accra, Ghana\'s capital, is one of West Africa\'s fastest-growing cities, with a population of over 3 million and a thriving arts and tech scene.',
  ),
  _Fact(
    emoji: '🌞',
    title: 'Tropical Climate',
    body:
        'Accra lies just 5° north of the equator, giving it a warm tropical climate year-round, with temperatures typically ranging from 24 °C to 32 °C.',
  ),
  _Fact(
    emoji: '🎶',
    title: 'Afrobeats Capital',
    body:
        'Ghana is a major hub of Afrobeats and highlife music, and Accra\'s vibrant nightlife scene draws music lovers from across Africa and the world.',
  ),
];
