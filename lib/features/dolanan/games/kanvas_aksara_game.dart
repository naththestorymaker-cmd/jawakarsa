import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/features/dolanan/games/aksara_evaluator.dart';
import 'package:jawakarsa/services/score_service.dart';
import 'package:jawakarsa/features/dolanan/widgets/gendhis_commentator.dart';

class _AksaraChallenge {
  const _AksaraChallenge({
    required this.aksara,
    required this.latin,
    required this.romanization,
  });
  final String aksara;
  final String latin;
  final String romanization;
}

const _challenges = [
  _AksaraChallenge(aksara: 'ꦲ', latin: 'Ha', romanization: 'ha'),
  _AksaraChallenge(aksara: 'ꦤ', latin: 'Na', romanization: 'na'),
  _AksaraChallenge(aksara: 'ꦕ', latin: 'Ca', romanization: 'ca'),
  _AksaraChallenge(aksara: 'ꦫ', latin: 'Ra', romanization: 'ra'),
  _AksaraChallenge(aksara: 'ꦏ', latin: 'Ka', romanization: 'ka'),
  _AksaraChallenge(aksara: 'ꦢ', latin: 'Da', romanization: 'da'),
  _AksaraChallenge(aksara: 'ꦠ', latin: 'Ta', romanization: 'ta'),
  _AksaraChallenge(aksara: 'ꦱ', latin: 'Sa', romanization: 'sa'),
  _AksaraChallenge(aksara: 'ꦮ', latin: 'Wa', romanization: 'wa'),
  _AksaraChallenge(aksara: 'ꦭ', latin: 'La', romanization: 'la'),
  _AksaraChallenge(aksara: 'ꦥ', latin: 'Pa', romanization: 'pa'),
  _AksaraChallenge(aksara: 'ꦝ', latin: 'Dha', romanization: 'dha'),
  _AksaraChallenge(aksara: 'ꦗ', latin: 'Ja', romanization: 'ja'),
  _AksaraChallenge(aksara: 'ꦪ', latin: 'Ya', romanization: 'ya'),
  _AksaraChallenge(aksara: 'ꦚ', latin: 'Nya', romanization: 'nya'),
  _AksaraChallenge(aksara: 'ꦩ', latin: 'Ma', romanization: 'ma'),
  _AksaraChallenge(aksara: 'ꦒ', latin: 'Ga', romanization: 'ga'),
  _AksaraChallenge(aksara: 'ꦧ', latin: 'Ba', romanization: 'ba'),
  _AksaraChallenge(aksara: 'ꦛ', latin: 'Tha', romanization: 'tha'),
  _AksaraChallenge(aksara: 'ꦔ', latin: 'Nga', romanization: 'nga'),
];

class _StarParticle {
  _StarParticle(Random rng)
      : angle = rng.nextDouble() * 2 * pi,
        distance = 35 + rng.nextDouble() * 95,
        size = 8 + rng.nextDouble() * 10,
        color = rng.nextBool()
            ? const Color(0xFFFFB84C)
            : const Color(0xFFFF8A80),
        opacity = 0.85 + rng.nextDouble() * 0.15;

  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double opacity;
}

class KanvasAksaraGame extends StatefulWidget {
  const KanvasAksaraGame({super.key});

  @override
  State<KanvasAksaraGame> createState() => _KanvasAksaraGameState();
}

class _KanvasAksaraGameState extends State<KanvasAksaraGame>
    with SingleTickerProviderStateMixin {
  int _currentIdx = 0;
  int _score = 0;
  bool _submitted = false;
  bool _gameOver = false;
  bool _showGuide = false;
  int _failAttempts = 0;

  AksaraEvaluation? _lastEvaluation;

  final List<Offset?> _rawPoints = [];
  final _pointsNotifier = ValueNotifier<List<Offset?>>([]);
  final _gendhisKey = GlobalKey<GendhisCommentatorState>();
  Timer? _thinkTimer;

  List<_StarParticle> _stars = [];
  late AnimationController _starCtrl;
  late Animation<double> _starAnim;
  final _starProgressNotifier = ValueNotifier<double>(0.0);

  final _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _starAnim = CurvedAnimation(parent: _starCtrl, curve: Curves.easeOut);
    _starCtrl.addListener(() => _starProgressNotifier.value = _starAnim.value);
    _startThinkTimer();
  }

  @override
  void dispose() {
    _thinkTimer?.cancel();
    _starCtrl.dispose();
    _pointsNotifier.dispose();
    _starProgressNotifier.dispose();
    super.dispose();
  }

  void _startThinkTimer() {
    _thinkTimer?.cancel();
    _thinkTimer = Timer(const Duration(seconds: 12), () {
      if (!_submitted && mounted) _gendhisKey.currentState?.thinking();
    });
  }

  void _onPanStart(DragStartDetails d) {
    if (_submitted) return;
    _thinkTimer?.cancel();
    _startThinkTimer();
    _rawPoints.add(d.localPosition);
    _pointsNotifier.value = List.unmodifiable(_rawPoints);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_submitted) return;
    _rawPoints.add(d.localPosition);
    _pointsNotifier.value = List.unmodifiable(_rawPoints);
    _thinkTimer?.cancel();
    _startThinkTimer();
  }

  void _onPanEnd(DragEndDetails d) {
    if (_submitted) return;
    _rawPoints.add(null);
    _pointsNotifier.value = List.unmodifiable(_rawPoints);
  }

  void _clear() {
    _rawPoints.clear();
    _pointsNotifier.value = [];
    setState(() {
      _lastEvaluation = null;
    });
  }

  void _submit() {
    if (_pointsNotifier.value.isEmpty || _submitted) return;

    final challenge = _challenges[_currentIdx];
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final canvasSize = box?.size ?? const Size(320, 260);

    final strokePoints = _rawPoints.map((p) {
      return p != null ? StrokePoint(p.dx, p.dy) : null;
    }).toList();

    final eval = AksaraEvaluator.evaluate(
      aksara: challenge.aksara,
      points: strokePoints,
      canvasWidth: canvasSize.width,
      canvasHeight: canvasSize.height,
    );

    setState(() {
      _lastEvaluation = eval;
    });

    if (eval.isPassed) {
      final rng = Random();
      final bonus = eval.accuracy >= 85
          ? 20
          : (eval.accuracy >= 70 ? 10 : 0);
      final gainedScore = ScoreService.rewardPerGame + bonus;

      setState(() {
        _submitted = true;
        _failAttempts = 0;
        _score += gainedScore;
        _stars = List.generate(20, (_) => _StarParticle(rng));
      });

      _starCtrl.forward(from: 0);
      _thinkTimer?.cancel();
      _gendhisKey.currentState?.correct();

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _advanceToNext();
      });
    } else {
      setState(() {
        _failAttempts++;
      });
      _gendhisKey.currentState?.wrong();
    }
  }

  void _advanceToNext() {
    if (_currentIdx < _challenges.length - 1) {
      setState(() {
        _currentIdx++;
        _submitted = false;
        _lastEvaluation = null;
        _failAttempts = 0;
        _stars = [];
      });
      _rawPoints.clear();
      _pointsNotifier.value = [];
      _starProgressNotifier.value = 0;
      _starCtrl.reset();
      _startThinkTimer();
    } else {
      setState(() => _gameOver = true);
      ScoreService.instance.submitScore(GameType.kanvas, _score);
      _gendhisKey.currentState?.completed(_score);
    }
  }

  void _skipChallenge() {
    setState(() {
      _failAttempts = 0;
      _lastEvaluation = null;
    });
    _advanceToNext();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_currentIdx];
    final screenH = MediaQuery.sizeOf(context).height;
    final canvasH = (screenH * 0.42).clamp(230.0, 330.0);

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
        title: Text('Kanvas Aksara', style: AppTextStyles.titleSmall()),
        actions: [
          IconButton(
            tooltip: _showGuide ? 'Sembunyikan Panduan' : 'Tampilkan Panduan',
            icon: Icon(
              _showGuide ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
              color: _showGuide ? AppColors.goldVarnishBrown : AppColors.coastalStorm,
            ),
            onPressed: () => setState(() => _showGuide = !_showGuide),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_score poin',
                style: AppTextStyles.labelLarge(
                    color: AppColors.goldVarnishBrown),
              ),
            ),
          ),
        ],
      ),
      body: _gameOver
          ? _GameOverScreen(
              score: _score, onBack: () => Navigator.pop(context))
          : Stack(
              children: [
                SingleChildScrollView(
                  physics: _submitted
                      ? const NeverScrollableScrollPhysics()
                      : const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProgressBar(
                          current: _currentIdx + 1,
                          total: _challenges.length),
                      const SizedBox(height: 14),
                      _ChallengeHeader(
                        challenge: challenge,
                        showGuide: _showGuide,
                        onToggleGuide: () =>
                            setState(() => _showGuide = !_showGuide),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        key: _canvasKey,
                        height: canvasH,
                        child: _DrawingCanvas(
                          pointsNotifier: _pointsNotifier,
                          starProgressNotifier: _starProgressNotifier,
                          ghostAksara: challenge.aksara,
                          submitted: _submitted,
                          stars: _stars,
                          showGuide: _showGuide,
                          onPanStart: _submitted ? null : _onPanStart,
                          onPanUpdate: _submitted ? null : _onPanUpdate,
                          onPanEnd: _submitted ? null : _onPanEnd,
                        ),
                      ),

                      if (_lastEvaluation != null) ...[
                        const SizedBox(height: 12),
                        _EvaluationBanner(
                          evaluation: _lastEvaluation!,
                          onRetry: _clear,
                          onKeepAndImprove: () => setState(() {
                            _lastEvaluation = null;
                          }),
                          onSkip: _failAttempts >= 2 ? _skipChallenge : null,
                        ),
                      ],

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _submitted ? null : _clear,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.potBlack,
                                side: BorderSide(
                                    color: AppColors.coastalStorm
                                        .withValues(alpha: 0.5)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text('Hapus',
                                  style: AppTextStyles.titleSmall(
                                      color: AppColors.potBlack)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ValueListenableBuilder<List<Offset?>>(
                              valueListenable: _pointsNotifier,
                              builder: (context, pts, _) {
                                final hasPoints = pts.isNotEmpty;
                                return ElevatedButton(
                                  onPressed: (_submitted || !hasPoints)
                                      ? null
                                      : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.rubyRed,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.rubyRed
                                        .withValues(alpha: 0.4),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: Text(
                                    _submitted ? 'Lanjut...' : 'Cek Goresan',
                                    style: AppTextStyles.titleSmall(
                                        color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GendhisCommentator(key: _gendhisKey),
              ],
            ),
    );
  }
}

class _DrawingCanvas extends StatelessWidget {
  const _DrawingCanvas({
    required this.pointsNotifier,
    required this.starProgressNotifier,
    required this.ghostAksara,
    required this.submitted,
    required this.stars,
    required this.showGuide,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  final ValueNotifier<List<Offset?>> pointsNotifier;
  final ValueNotifier<double> starProgressNotifier;
  final String ghostAksara;
  final bool submitted;
  final List<_StarParticle> stars;
  final bool showGuide;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: submitted
                ? AppColors.mallardish.withValues(alpha: 0.6)
                : AppColors.coastalStorm.withValues(alpha: 0.3),
            width: submitted ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size =
                  Size(constraints.maxWidth, constraints.maxHeight);
              return ListenableBuilder(
                listenable: Listenable.merge(
                    [pointsNotifier, starProgressNotifier]),
                builder: (context, _) => CustomPaint(
                  painter: _CanvasPainter(
                    points: pointsNotifier.value,
                    ghostAksara: ghostAksara,
                    stars: stars,
                    starProgress: starProgressNotifier.value,
                    showGuide: showGuide,
                  ),
                  size: size,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({
    required this.points,
    required this.ghostAksara,
    required this.stars,
    required this.starProgress,
    required this.showGuide,
  });

  final List<Offset?> points;
  final String ghostAksara;
  final List<_StarParticle> stars;
  final double starProgress;
  final bool showGuide;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ghostFontSize = (size.shortestSide * 0.60).clamp(76.0, 168.0);

    final tp = TextPainter(
      text: TextSpan(
        text: ghostAksara,
        style: GoogleFonts.notoSansJavanese(
          fontSize: ghostFontSize,
          color: const Color(0xFFC7CFE2),
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    final ghostTopLeft = center - Offset(tp.width / 2, tp.height / 2);
    tp.paint(canvas, ghostTopLeft);

    if (showGuide) {
      final targetRect = Rect.fromCenter(
        center: center,
        width: (size.width * 0.70).clamp(160.0, 260.0),
        height: (size.height * 0.68).clamp(140.0, 220.0),
      );
      final rawWaypoints = AksaraEvaluator.getWaypointsFor(ghostAksara);

      final guidePaint = Paint()
        ..color = AppColors.goldVarnishBrown.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < rawWaypoints.length; i++) {
        final wp = rawWaypoints[i];
        final pt = Offset(
          targetRect.left + wp.x * targetRect.width,
          targetRect.top + wp.y * targetRect.height,
        );
        canvas.drawCircle(pt, 4.0, guidePaint);
      }
    }

    if (points.isNotEmpty) {
      final strokePaint = Paint()
        ..color = AppColors.potBlack
        ..strokeWidth = (size.shortestSide * 0.016).clamp(4.0, 7.0)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final dotPaint = Paint()
        ..color = AppColors.potBlack
        ..style = PaintingStyle.fill;

      for (int i = 0; i < points.length; i++) {
        final current = points[i];
        if (current == null) continue;

        final hasPrev = i > 0 && points[i - 1] != null;
        final hasNext = i < points.length - 1 && points[i + 1] != null;

        if (!hasPrev && !hasNext) {
          canvas.drawCircle(current, strokePaint.strokeWidth / 2, dotPaint);
        } else if (hasNext) {
          canvas.drawLine(current, points[i + 1]!, strokePaint);
        }
      }
    }

    if (starProgress > 0 && stars.isNotEmpty) {
      for (final star in stars) {
        double starSize;
        Offset starPos;

        if (starProgress < 0.3) {
          final gather = starProgress / 0.3;
          starSize = star.size * gather * 0.4;
          starPos = center;
        } else {
          final explode = (starProgress - 0.3) / 0.7;
          final eased = 1 - pow(1 - explode, 2).toDouble();
          starSize = star.size * (0.4 + eased * 0.6);
          starPos = Offset(
            center.dx + cos(star.angle) * star.distance * eased,
            center.dy + sin(star.angle) * star.distance * eased,
          );
        }

        final fadeOut = starProgress > 0.7
            ? 1 - ((starProgress - 0.7) / 0.3)
            : 1.0;

        final p = Paint()
          ..color = star.color
              .withValues(alpha: star.opacity * fadeOut.clamp(0.0, 1.0));
        canvas.drawPath(_starPath(starPos, starSize, 5), p);
      }
    }
  }

  Path _starPath(Offset center, double radius, int pts) {
    if (radius < 1) return Path();
    final path = Path();
    final inner = radius * 0.4;
    for (int i = 0; i < pts * 2; i++) {
      final angle = (i * pi / pts) - pi / 2;
      final r = i.isEven ? radius : inner;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_CanvasPainter old) =>
      !identical(old.points, points) ||
      old.starProgress != starProgress ||
      old.ghostAksara != ghostAksara ||
      old.showGuide != showGuide;
}

class _EvaluationBanner extends StatelessWidget {
  const _EvaluationBanner({
    required this.evaluation,
    required this.onRetry,
    required this.onKeepAndImprove,
    this.onSkip,
  });

  final AksaraEvaluation evaluation;
  final VoidCallback onRetry;
  final VoidCallback onKeepAndImprove;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final isPassed = evaluation.isPassed;
    final color = isPassed ? AppColors.mallardish : AppColors.rubyRed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPassed ? Icons.check_circle_rounded : Icons.info_rounded,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Akurasi: ${evaluation.accuracy}% • ${evaluation.ratingText}',
                  style: AppTextStyles.titleSmall(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            evaluation.feedback,
            style: AppTextStyles.bodyMedium(color: AppColors.potBlack),
          ),
          if (!isPassed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Hapus & Ulangi'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.rubyRed,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                TextButton.icon(
                  onPressed: onKeepAndImprove,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Lengkapi Goresan'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mallardish,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                if (onSkip != null) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.coastalStorm,
                    ),
                    child: const Text('Lewati'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChallengeHeader extends StatelessWidget {
  const _ChallengeHeader({
    required this.challenge,
    required this.showGuide,
    required this.onToggleGuide,
  });

  final _AksaraChallenge challenge;
  final bool showGuide;
  final VoidCallback onToggleGuide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.mallardish.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium(),
                children: [
                  const TextSpan(text: 'Goreskan aksara '),
                  TextSpan(
                    text: challenge.romanization,
                    style:
                        AppTextStyles.bodyMedium(color: AppColors.potBlack)
                            .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' mengikuti bayangan huruf.'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mallardish.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              challenge.latin,
              style:
                  AppTextStyles.titleSmall(color: AppColors.mallardish),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$current / $total',
            style:
                AppTextStyles.labelSmall(color: AppColors.coastalStorm)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor:
                AppColors.coastalStorm.withValues(alpha: 0.2),
            color: AppColors.mallardish,
            minHeight: 6,
          ),
        ),
      ],
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
            Text('Semua Aksara Selesai!',
                style: AppTextStyles.headlineMedium()),
            const SizedBox(height: 8),
            Text('Total Skor: $score poin',
                style: AppTextStyles.titleMedium(
                    color: AppColors.goldVarnishBrown)),
            const SizedBox(height: 8),
            Text('Skor kamu sudah tersimpan!',
                style: AppTextStyles.bodyMedium(),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mallardish,
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
