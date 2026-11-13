import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/services/score_service.dart';
import 'package:jawakarsa/features/dolanan/widgets/gendhis_commentator.dart';

class _MatchPair {
  const _MatchPair({required this.term, required this.definition});
  final String term;
  final String definition;
}

const _pool = [
  _MatchPair(term: 'Wayang', definition: 'Seni pertunjukan boneka kulit'),
  _MatchPair(term: 'Gamelan', definition: 'Musik tradisional Jawa'),
  _MatchPair(term: 'Batik', definition: 'Kain motif dengan lilin'),
  _MatchPair(term: 'Keraton', definition: 'Istana raja Jawa'),
  _MatchPair(term: 'Gudeg', definition: 'Masakan nangka muda khas Yogya'),
  _MatchPair(term: 'Dalang', definition: 'Pemain utama pertunjukan wayang'),
  _MatchPair(term: 'Krama', definition: 'Bahasa Jawa halus/formal'),
  _MatchPair(term: 'Joglo', definition: 'Rumah tradisional atap tinggi'),
  _MatchPair(term: 'Rebab', definition: 'Alat musik gesek gamelan'),
  _MatchPair(term: 'Kipo', definition: 'Jajanan mungil khas Kotagede'),
  _MatchPair(term: 'Parang', definition: 'Motif batik larangan keraton'),
  _MatchPair(term: 'Senthong', definition: 'Ruang sakral rumah Jawa'),
  _MatchPair(term: 'Lurik', definition: 'Kain tenun bergaris khas Jawa'),
  _MatchPair(term: 'Kendang', definition: 'Pemimpin tempo dalam gamelan'),
  _MatchPair(term: 'Lakon', definition: 'Cerita dalam pertunjukan wayang'),
  _MatchPair(term: 'Ngoko', definition: 'Bahasa Jawa tingkat akrab'),
  _MatchPair(term: 'Punden', definition: 'Tempat keramat di desa Jawa'),
  _MatchPair(term: 'Gunungan', definition: 'Wayang berbentuk gunung/pohon'),
];

class CocokologiGame extends StatefulWidget {
  const CocokologiGame({super.key});

  @override
  State<CocokologiGame> createState() => _CocokologiGameState();
}

class _CocokologiGameState extends State<CocokologiGame> {
  late List<_MatchPair> _roundPairs;
  late List<String> _leftTerms;
  late List<String> _rightDefs;
  final Map<String, String> _matched = {};
  final Set<String> _usedTerms = {};
  String? _selectedTerm;
  int _score = 0;
  int _round = 0;
  bool _gameOver = false;
  static const _totalRounds = 3;
  static const _pairsPerRound = 5;
  final _gendhisKey = GlobalKey<GendhisCommentatorState>();
  Timer? _thinkTimer;

  @override
  void initState() {
    super.initState();
    _loadRound();
  }

  @override
  void dispose() {
    _thinkTimer?.cancel();
    super.dispose();
  }

  void _loadRound() {
    final rng = Random();
    final available = _pool
        .where((p) => !_usedTerms.contains(p.term))
        .toList()
      ..shuffle(rng);

    if (available.length < _pairsPerRound) {
      _usedTerms.clear();
      final refilled = List<_MatchPair>.from(_pool)..shuffle(rng);
      _roundPairs = refilled.take(_pairsPerRound).toList();
    } else {
      _roundPairs = available.take(_pairsPerRound).toList();
    }

    for (final p in _roundPairs) {
      _usedTerms.add(p.term);
    }

    _leftTerms = _roundPairs.map((p) => p.term).toList();
    _rightDefs = _roundPairs.map((p) => p.definition).toList()..shuffle(rng);
    _matched.clear();
    _selectedTerm = null;
    _startThinkTimer();
  }

  void _startThinkTimer() {
    _thinkTimer?.cancel();
    _thinkTimer = Timer(const Duration(seconds: 12), () {
      if (!_gameOver && mounted) _gendhisKey.currentState?.thinking();
    });
  }

  void _onTermTap(String term) {
    if (_matched.containsKey(term)) return;
    setState(() => _selectedTerm = _selectedTerm == term ? null : term);
  }

  void _onDefTap(String definition) {
    if (_matched.values.contains(definition)) return;
    final term = _selectedTerm;
    if (term == null) return;
    _matchAttempt(term, definition);
  }

  void _onDrop(String term, String definition) =>
      _matchAttempt(term, definition);

  void _matchAttempt(String term, String definition) {
    final correct =
        _roundPairs.any((p) => p.term == term && p.definition == definition);
    setState(() {
      if (correct) {
        _matched[term] = definition;
        _selectedTerm = null;
        _score += ScoreService.rewardPerGame;
        _gendhisKey.currentState?.correct();
        if (_matched.length == _roundPairs.length) {
          _thinkTimer?.cancel();
          if (_round < _totalRounds - 1) {
            Future.delayed(const Duration(milliseconds: 700), () {
              if (!mounted) return;
              setState(() {
                _round++;
                _loadRound();
              });
            });
          } else {
            Future.delayed(const Duration(milliseconds: 700), () {
              if (!mounted) return;
              setState(() => _gameOver = true);
              ScoreService.instance.submitScore(GameType.cocok, _score);
              _gendhisKey.currentState?.completed(_score);
            });
          }
        }
      } else {
        _selectedTerm = null;
        _gendhisKey.currentState?.wrong();
      }
    });
    _thinkTimer?.cancel();
    _startThinkTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.coastalStorm.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded,
                color: AppColors.potBlack, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Cocokologi Budaya', style: AppTextStyles.titleSmall()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('$_score poin',
                  style: AppTextStyles.labelLarge(
                      color: AppColors.goldVarnishBrown)),
            ),
          ),
        ],
      ),
      body: _gameOver
          ? _GameOverScreen(
              score: _score, onBack: () => Navigator.pop(context))
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedTerm != null
                                  ? 'Pilih makna untuk "$_selectedTerm"'
                                  : 'Ketuk atau seret kata ke maknanya.',
                              style: AppTextStyles.bodyMedium(
                                color: _selectedTerm != null
                                    ? AppColors.rubyRed
                                    : AppColors.coastalStorm,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.goldVarnishBrown,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Ronde ${_round + 1}/$_totalRounds',
                              style: AppTextStyles.labelSmall(
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text('Kata',
                                    style: AppTextStyles.labelLarge(
                                        color: AppColors.rubyRed)),
                              ),
                            ),
                            const SizedBox(width: 48),
                            Expanded(
                              child: Center(
                                child: Text('Makna',
                                    style: AppTextStyles.labelLarge(
                                        color: AppColors.mallardish)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: _MatchingBoard(
                          leftTerms: _leftTerms,
                          rightDefs: _rightDefs,
                          matched: _matched,
                          roundPairs: _roundPairs,
                          selectedTerm: _selectedTerm,
                          onTermTap: _onTermTap,
                          onDefTap: _onDefTap,
                          onDrop: _onDrop,
                        ),
                      ),
                      _MatchFooter(
                          matched: _matched.length,
                          total: _pairsPerRound),
                    ],
                  ),
                ),
                GendhisCommentator(key: _gendhisKey),
              ],
            ),
    );
  }
}

class _MatchingBoard extends StatelessWidget {
  const _MatchingBoard({
    required this.leftTerms,
    required this.rightDefs,
    required this.matched,
    required this.roundPairs,
    required this.selectedTerm,
    required this.onTermTap,
    required this.onDefTap,
    required this.onDrop,
  });

  final List<String> leftTerms;
  final List<String> rightDefs;
  final Map<String, String> matched;
  final List<_MatchPair> roundPairs;
  final String? selectedTerm;
  final ValueChanged<String> onTermTap;
  final ValueChanged<String> onDefTap;
  final void Function(String, String) onDrop;

  @override
  Widget build(BuildContext context) {
    final n = leftTerms.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalH = constraints.maxHeight;
        // Hitung gap dan tinggi kartu secara adaptif agar seimbang mengisi seluruh area vertikal
        final gap = totalH > 520 ? 12.0 : (totalH > 440 ? 10.0 : 8.0);
        final rawCardH = (totalH - (n - 1) * gap) / n;
        final cardH = rawCardH.clamp(48.0, 120.0);

        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: leftTerms.asMap().entries.map((e) {
                      final term = e.value;
                      final isMatched = matched.containsKey(term);
                      final isSelected = selectedTerm == term;
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: e.key < n - 1 ? gap : 0),
                        child: SizedBox(
                          height: cardH,
                          child: Draggable<String>(
                            data: term,
                            onDraggableCanceled: (_, _) {},
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: (constraints.maxWidth - 48) / 2,
                                height: cardH,
                                child: _TermTile(
                                  term: term,
                                  matched: false,
                                  selected: false,
                                  dragging: true,
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _TermTile(
                                  term: term,
                                  matched: isMatched,
                                  selected: false,
                                  dragging: false),
                            ),
                            child: GestureDetector(
                              onTap: () => onTermTap(term),
                              child: _TermTile(
                                term: term,
                                matched: isMatched,
                                selected: isSelected,
                                dragging: false,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Jalur tengah — 48px untuk garis penghubung
                SizedBox(
                  width: 48,
                  child: CustomPaint(
                    painter: _ConnectorPainter(
                      leftTerms: leftTerms,
                      rightDefs: rightDefs,
                      matched: matched,
                      roundPairs: roundPairs,
                      cardH: cardH,
                      gap: gap,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: rightDefs.asMap().entries.map((e) {
                      final def = e.value;
                      final isMatched = matched.values.contains(def);
                      final isTargetable =
                          selectedTerm != null && !isMatched;
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: e.key < n - 1 ? gap : 0),
                        child: SizedBox(
                          height: cardH,
                          child: DragTarget<String>(
                            onAcceptWithDetails: (d) =>
                                onDrop(d.data, def),
                            builder: (context, candidates, _) {
                              return GestureDetector(
                                onTap: () => onDefTap(def),
                                child: _DefTile(
                                  definition: def,
                                  matched: isMatched,
                                  hovering: candidates.isNotEmpty,
                                  targetable: isTargetable,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Painter garis penghubung di area tengah
class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.leftTerms,
    required this.rightDefs,
    required this.matched,
    required this.roundPairs,
    required this.cardH,
    required this.gap,
  });

  final List<String> leftTerms;
  final List<String> rightDefs;
  final Map<String, String> matched;
  final List<_MatchPair> roundPairs;
  final double cardH;
  final double gap;

  double _centerY(int idx) => idx * (cardH + gap) + cardH / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final pair in roundPairs) {
      final termIdx = leftTerms.indexOf(pair.term);
      final defIdx = rightDefs.indexOf(pair.definition);
      if (termIdx < 0 || defIdx < 0) continue;

      final isConnected = matched[pair.term] == pair.definition;

      if (isConnected) {
        paint.color = AppColors.mallardish;
      } else {
        continue;
      }

      final startY = _centerY(termIdx);
      final endY = _centerY(defIdx);
      final startX = 0.0;
      final endX = size.width;

      final path = Path()
        ..moveTo(startX, startY)
        ..cubicTo(
          size.width * 0.35,
          startY,
          size.width * 0.65,
          endY,
          endX,
          endY,
        );

      canvas.drawPath(path, paint);

      // Titik di ujung garis
      final dotPaint = Paint()
        ..color = AppColors.mallardish
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(startX + 4, startY), 4, dotPaint);
      canvas.drawCircle(Offset(endX - 4, endY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.matched.length != matched.length;
}

class _TermTile extends StatelessWidget {
  const _TermTile({
    required this.term,
    required this.matched,
    required this.selected,
    required this.dragging,
  });
  final String term;
  final bool matched;
  final bool selected;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;

    if (matched) {
      bg = AppColors.mallardish.withValues(alpha: 0.1);
      border = AppColors.mallardish;
      textColor = AppColors.mallardish;
    } else if (selected) {
      bg = AppColors.rubyRed.withValues(alpha: 0.08);
      border = AppColors.rubyRed;
      textColor = AppColors.rubyRed;
    } else if (dragging) {
      bg = AppColors.goldVarnishBrown.withValues(alpha: 0.12);
      border = AppColors.goldVarnishBrown;
      textColor = AppColors.potBlack;
    } else {
      bg = AppColors.surface;
      border = AppColors.rubyRed.withValues(alpha: 0.3);
      textColor = AppColors.potBlack;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: selected ? 2 : 1.5),
        boxShadow: (selected || dragging)
            ? [
                BoxShadow(
                  color: (selected ? AppColors.rubyRed : AppColors.potBlack)
                      .withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            term,
            style: AppTextStyles.titleSmall(color: textColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _DefTile extends StatelessWidget {
  const _DefTile({
    required this.definition,
    required this.matched,
    required this.hovering,
    required this.targetable,
  });
  final String definition;
  final bool matched;
  final bool hovering;
  final bool targetable;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;

    if (matched) {
      bg = AppColors.mallardish.withValues(alpha: 0.08);
      border = AppColors.mallardish;
      textColor = AppColors.mallardish;
    } else if (hovering) {
      bg = AppColors.rubyRed.withValues(alpha: 0.08);
      border = AppColors.rubyRed;
      textColor = AppColors.potBlack;
    } else if (targetable) {
      bg = AppColors.goldVarnishBrown.withValues(alpha: 0.06);
      border = AppColors.goldVarnishBrown.withValues(alpha: 0.5);
      textColor = AppColors.potBlack;
    } else {
      bg = AppColors.surface;
      border = AppColors.mallardish.withValues(alpha: 0.3);
      textColor = AppColors.potBlack;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: border,
            width: (matched || hovering) ? 2 : 1.5),
        boxShadow: (hovering || targetable)
            ? [
                BoxShadow(
                  color: AppColors.potBlack.withValues(alpha: 0.06),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            definition,
            style: AppTextStyles.bodyMedium(color: textColor),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _MatchFooter extends StatelessWidget {
  const _MatchFooter({required this.matched, required this.total});
  final int matched;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? matched / total : 0,
                backgroundColor:
                    AppColors.coastalStorm.withValues(alpha: 0.2),
                color: AppColors.mallardish,
                minHeight: 7,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$matched / $total cocok',
            style: AppTextStyles.labelLarge(color: AppColors.mallardish),
          ),
        ],
      ),
    );
  }
}

class _GameOverScreen extends StatelessWidget {
  const _GameOverScreen({required this.score, required this.onBack});
  final int score;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: AppColors.goldVarnishBrown, size: 64),
            const SizedBox(height: 20),
            Text('Cocokologi Selesai!',
                style: AppTextStyles.headlineMedium()),
            const SizedBox(height: 8),
            Text('Total Skor: $score poin',
                style: AppTextStyles.titleMedium(
                    color: AppColors.goldVarnishBrown)),
            const SizedBox(height: 8),
            Text('Skor sudah disimpan!',
                style: AppTextStyles.bodyMedium(),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldVarnishBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Kembali',
                    style: AppTextStyles.titleSmall(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
