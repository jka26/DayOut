import 'package:flutter/material.dart';
import '../models/plan_store.dart';

// ── Data models ────────────────────────────────────────────────────────────────

class SurpriseStop {
  final String name;
  final String emoji;
  final String category;
  final Color color;
  final String suggestedTime;
  final String note;

  const SurpriseStop({
    required this.name,
    required this.emoji,
    required this.category,
    required this.color,
    required this.suggestedTime,
    required this.note,
  });
}

class SurprisePlan {
  final String name;
  final String tagline;
  final List<SurpriseStop> stops;

  const SurprisePlan({
    required this.name,
    required this.tagline,
    required this.stops,
  });

  SavedPlan toSavedPlan() => SavedPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: DateTime.now(),
        stops: stops
            .map((s) => StopInfo(
                  name: s.name,
                  color: s.color,
                  emoji: s.emoji,
                  category: s.category,
                ))
            .toList(),
        friendInitials: const [],
        isSurprise: true,
      );
}

// ── Place database ─────────────────────────────────────────────────────────────

class _Place {
  final String name;
  final String emoji;
  final String category;
  final Color color;
  final int priceTier; // 1=budget, 2=mid, 3=premium
  final Set<String> vibes; // outdoor,active,chill,food,family,fun,cultural,date,nightlife
  final Set<String> times; // morning,midday,evening,night
  final String note;

  const _Place({
    required this.name,
    required this.emoji,
    required this.category,
    required this.color,
    required this.priceTier,
    required this.vibes,
    required this.times,
    required this.note,
  });
}

const _places = <_Place>[
  _Place(
    name: 'Labadi Beach',
    emoji: '🏖️',
    category: 'Beach',
    color: Color(0xFF00C2CC),
    priceTier: 1,
    vibes: {'outdoor', 'active', 'chill', 'family', 'date'},
    times: {'morning', 'midday', 'evening'},
    note: 'Great for a swim or a stroll along the shore.',
  ),
  _Place(
    name: 'Bojo Beach',
    emoji: '🌊',
    category: 'Beach',
    color: Color(0xFF0EA5E9),
    priceTier: 2,
    vibes: {'outdoor', 'chill', 'date', 'active'},
    times: {'morning', 'midday', 'evening'},
    note: 'Quieter and cleaner — perfect for a laid-back beach day.',
  ),
  _Place(
    name: 'Aburi Botanical Garden',
    emoji: '🌿',
    category: 'Park',
    color: Color(0xFF22C55E),
    priceTier: 1,
    vibes: {'outdoor', 'active', 'family', 'chill', 'cultural'},
    times: {'morning', 'midday'},
    note: 'Lush green escape from the city — bring a picnic.',
  ),
  _Place(
    name: 'Kwame Nkrumah Mausoleum',
    emoji: '🏛️',
    category: 'Historical',
    color: Color(0xFF6B7280),
    priceTier: 1,
    vibes: {'cultural', 'fun', 'family'},
    times: {'morning', 'midday'},
    note: 'Iconic memorial — learn about Ghana\'s founding history.',
  ),
  _Place(
    name: 'National Museum of Ghana',
    emoji: '🏺',
    category: 'Museum',
    color: Color(0xFFF59E0B),
    priceTier: 1,
    vibes: {'cultural', 'fun', 'family'},
    times: {'morning', 'midday'},
    note: 'Explore Ghana\'s rich art and archaeological heritage.',
  ),
  _Place(
    name: 'Jamestown Lighthouse',
    emoji: '🔦',
    category: 'Historical',
    color: Color(0xFFEF4444),
    priceTier: 1,
    vibes: {'cultural', 'outdoor', 'fun', 'date'},
    times: {'morning', 'midday'},
    note: 'Panoramic views of Accra\'s historic fishing district.',
  ),
  _Place(
    name: 'Santoku Restaurant',
    emoji: '🍜',
    category: 'Restaurant',
    color: Color(0xFFE91E8C),
    priceTier: 2,
    vibes: {'food', 'date', 'chill'},
    times: {'midday', 'evening'},
    note: 'Asian-inspired cuisine with a chic atmosphere.',
  ),
  _Place(
    name: 'Republic Bar & Grill',
    emoji: '🍖',
    category: 'Restaurant',
    color: Color(0xFFFF6B35),
    priceTier: 2,
    vibes: {'food', 'chill', 'date'},
    times: {'midday', 'evening'},
    note: 'Lively spot with great grills and cocktails.',
  ),
  _Place(
    name: 'Bush Canteen',
    emoji: '🍲',
    category: 'Restaurant',
    color: Color(0xFF84CC16),
    priceTier: 1,
    vibes: {'food', 'family', 'chill'},
    times: {'midday', 'evening'},
    note: 'Local Ghanaian dishes — fufu, banku, and more.',
  ),
  _Place(
    name: 'Silverbird Cinemas',
    emoji: '🎬',
    category: 'Cinema',
    color: Color(0xFF7C3AED),
    priceTier: 2,
    vibes: {'fun', 'date', 'family'},
    times: {'midday', 'evening', 'night'},
    note: 'Catch the latest blockbuster at the city\'s top cinema.',
  ),
  _Place(
    name: 'GameZone Osu',
    emoji: '🕹️',
    category: 'Arcade',
    color: Color(0xFF7C3AED),
    priceTier: 2,
    vibes: {'fun', 'active', 'family'},
    times: {'midday', 'evening', 'night'},
    note: 'Bowling, games, and good times with the crew.',
  ),
  _Place(
    name: 'Kiza Rooftop',
    emoji: '🌙',
    category: 'Bar & Lounge',
    color: Color(0xFF1D4ED8),
    priceTier: 3,
    vibes: {'chill', 'date', 'nightlife'},
    times: {'evening', 'night'},
    note: 'Stunning rooftop views with cocktails and Afrobeats.',
  ),
  _Place(
    name: 'Firefly Lounge',
    emoji: '🔥',
    category: 'Bar & Lounge',
    color: Color(0xFFDC2626),
    priceTier: 2,
    vibes: {'chill', 'date', 'nightlife'},
    times: {'evening', 'night'},
    note: 'Cosy lounge with creative cocktails and live music.',
  ),
  _Place(
    name: 'National Theatre',
    emoji: '🎭',
    category: 'Theatre',
    color: Color(0xFF9333EA),
    priceTier: 1,
    vibes: {'cultural', 'fun', 'family', 'date'},
    times: {'evening'},
    note: 'Local plays, dance performances, and cultural shows.',
  ),
  _Place(
    name: 'Accra Mall',
    emoji: '🛍️',
    category: 'Mall',
    color: Color(0xFF0891B2),
    priceTier: 2,
    vibes: {'family', 'fun', 'chill'},
    times: {'morning', 'midday', 'evening'},
    note: 'Air-conditioned bliss — great for shopping and food court eats.',
  ),
  _Place(
    name: 'Marina Mall',
    emoji: '🏬',
    category: 'Mall',
    color: Color(0xFF0284C7),
    priceTier: 2,
    vibes: {'family', 'fun', 'chill'},
    times: {'morning', 'midday', 'evening'},
    note: 'Modern mall with a sea breeze — close to the coast.',
  ),
  _Place(
    name: 'Art Haus Osu',
    emoji: '🎨',
    category: 'Gallery',
    color: Color(0xFFF97316),
    priceTier: 1,
    vibes: {'cultural', 'date', 'chill'},
    times: {'morning', 'midday'},
    note: 'Contemporary Ghanaian art in a beautiful space.',
  ),
  _Place(
    name: 'La Palm Beach Hotel',
    emoji: '🌴',
    category: 'Beach Resort',
    color: Color(0xFF10B981),
    priceTier: 3,
    vibes: {'outdoor', 'chill', 'date', 'family'},
    times: {'morning', 'midday', 'evening'},
    note: 'Private beach, pool, and a relaxed upscale vibe.',
  ),
  _Place(
    name: 'Accra Polo Club',
    emoji: '🐎',
    category: 'Sports',
    color: Color(0xFF065F46),
    priceTier: 2,
    vibes: {'active', 'fun', 'date', 'outdoor'},
    times: {'morning', 'midday'},
    note: 'Unique experience — watch a polo match or take a ride.',
  ),
  _Place(
    name: 'Osu Night Market',
    emoji: '🌃',
    category: 'Market',
    color: Color(0xFFCA8A04),
    priceTier: 1,
    vibes: {'fun', 'food', 'cultural', 'nightlife'},
    times: {'evening', 'night'},
    note: 'Street food, crafts, and Accra\'s buzzing night energy.',
  ),
];

// ── Planner service ────────────────────────────────────────────────────────────

class SurprisePlannerService {
  // Maps vibe index (from SurpriseScreen) to tag strings
  static const List<Set<String>> _vibeTags = [
    {'outdoor', 'active'}, // 'Something outdoors & active'
    {'chill'},             // 'Chill with friends at a nice spot'
    {'food'},              // 'Good food is a must'
    {'family'},            // 'Family-friendly vibes'
    {'fun', 'cultural'},   // 'Something fun & nostalgic'
    <String>{},            // 'Budget-friendly day out' — handled via priceTier
  ];

  // Maps time index to tag + time slots
  static const _timeSlots = [
    ('morning',  ['9:00 AM', '11:00 AM', '1:00 PM',  '3:00 PM']),
    ('midday',   ['12:00 PM', '2:00 PM', '4:00 PM',  '6:00 PM']),
    ('evening',  ['4:00 PM',  '6:00 PM', '8:00 PM',  '10:00 PM']),
    ('night',    ['7:00 PM',  '9:00 PM', '10:30 PM', '12:00 AM']),
  ];

  static const _planNames = {
    'outdoor':   ['Golden Hour Outside', 'Accra in the Open Air', 'Under the Accra Sky'],
    'active':    ['Move & Groove Day',   'Active Day Out',        'On the Go in Accra'],
    'chill':     ['Chill Mode: Accra',   'Laid-Back Accra Day',   'Easy Vibes Day'],
    'food':      ['Accra Food Trail',    'Taste of Accra',        'Flavours of the City'],
    'family':    ['Family Fun Day',      'A Day with the Squad',  'All Together Now'],
    'fun':       ['Fun-Filled Friday',   'Nostalgia Trip',        'Best Day Ever'],
    'cultural':  ['Accra Culture Crawl', 'Roots & Routes',        'History & Vibes'],
    'date':      ['Date Night Accra',    'Romantic Accra Day',    'Just the Two of Us'],
    'nightlife': ['Accra After Dark',    'Night Owls in Accra',   'City Lights Night'],
    'default':   ['Surprise Day Out',    'Your Accra Adventure',  'DayOut Pick'],
  };

  static const _taglines = [
    'We picked these spots just for your vibe ✨',
    'Your perfect Accra day, planned by DayOut 🗓️',
    'Trust us — you\'re going to love this 🎉',
    'Sit back and enjoy the plan we made for you 🌟',
  ];

  static SurprisePlan generate({
    required Set<int> vibeIndices,
    required int timeIndex,
    required int budgetIndex,
  }) {
    // 1. Determine max price tier from budget
    final maxTier = switch (budgetIndex) {
      0 => 1, // Under GH₵50
      1 => 2, // GH₵50–150
      2 => 2, // GH₵150–300 (still mid, premium is very high)
      _ => 3, // No limit
    };

    // 2. Collect active vibe tags
    final activeTags = <String>{};
    final isBudgetFocused = vibeIndices.contains(5);
    for (final i in vibeIndices) {
      if (i < _vibeTags.length) activeTags.addAll(_vibeTags[i]);
    }

    // 3. Get time tag and slots
    final (timeTag, slots) = _timeSlots[timeIndex.clamp(0, 3)];
    final mustHaveFood = vibeIndices.contains(2);

    // 4. Score and filter places
    final candidates = _places
        .where((p) => p.priceTier <= maxTier && p.times.contains(timeTag))
        .map((p) {
          int score = 0;
          for (final tag in activeTags) {
            if (p.vibes.contains(tag)) score += 2;
          }
          if (isBudgetFocused && p.priceTier == 1) score += 2;
          // Boost food places if food vibe selected
          if (mustHaveFood && p.vibes.contains('food')) score += 3;
          return (p, score);
        })
        .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    // 5. Pick stops ensuring category variety
    final numStops = budgetIndex == 0 ? 2 : (budgetIndex >= 3 ? 4 : 3);
    final picked = <_Place>[];
    final usedCategories = <String>{};

    // Ensure a food stop if food vibe selected
    if (mustHaveFood) {
      final foodStop = candidates
          .map((e) => e.$1)
          .firstWhere(
            (p) => p.vibes.contains('food'),
            orElse: () => candidates.first.$1,
          );
      picked.add(foodStop);
      usedCategories.add(foodStop.category);
    }

    for (final (place, _) in candidates) {
      if (picked.length >= numStops) break;
      if (picked.contains(place)) continue;
      if (usedCategories.contains(place.category)) continue;
      picked.add(place);
      usedCategories.add(place.category);
    }

    // Fallback if not enough
    if (picked.isEmpty) picked.addAll(_places.take(numStops));

    // 6. Assign times
    final stops = picked.asMap().entries.map((e) {
      final time = slots.length > e.key ? slots[e.key] : slots.last;
      return SurpriseStop(
        name: e.value.name,
        emoji: e.value.emoji,
        category: e.value.category,
        color: e.value.color,
        suggestedTime: time,
        note: e.value.note,
      );
    }).toList();

    // 7. Generate plan name
    final primaryTag = activeTags.isNotEmpty ? activeTags.first : 'default';
    final nameList = _planNames[primaryTag] ?? _planNames['default']!;
    final nameIndex = DateTime.now().millisecond % nameList.length;
    final taglineIndex = DateTime.now().second % _taglines.length;

    return SurprisePlan(
      name: nameList[nameIndex],
      tagline: _taglines[taglineIndex],
      stops: stops,
    );
  }
}
