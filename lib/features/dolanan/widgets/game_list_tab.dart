import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/core/app_transitions.dart';
import 'package:jawakarsa/models/game_score.dart';
import 'package:jawakarsa/services/score_service.dart';
import 'package:jawakarsa/services/auth_service.dart';
import 'package:jawakarsa/features/dolanan/games/kanvas_aksara_game.dart';
import 'package:jawakarsa/features/dolanan/games/tts_jawa_game.dart';
import 'package:jawakarsa/features/dolanan/games/cocokologi_game.dart';

class GameListTab extends StatefulWidget {
  const GameListTab({super.key});

  @override
  State<GameListTab> createState() => _GameListTabState();
}

class _GameListTabState extends State<GameListTab> {
  String? _myUid;

  @override
  void initState() {
    super.initState();
    _loadUid();
    ScoreService.instance.refreshLeaderboard();
  }

  Future<void> _loadUid() async {
    final uid = await AuthService.instance.getSavedUid();
    if (mounted) setState(() => _myUid = uid);
  }

  void _pushGame(BuildContext context, Widget page) {
    Navigator.of(context)
        .push(AppTransitions.fadeSlideRoute(page: page))
        .then((_) => ScoreService.instance.refreshLeaderboard());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        StreamBuilder<List<GameScore>>(
          stream: ScoreService.instance.leaderboardStream(),
          builder: (context, snap) {
            final scores = snap.data ?? [];
            GameScore? mine;
            if (_myUid != null) {
              try {
                mine = scores.firstWhere((s) => s.uid == _myUid);
              } catch (_) {}
            }
            return _ScoreBanner(mine: mine);
          },
        ),
        const SizedBox(height: 20),
        _GameCard(
          icon: Icons.draw_rounded,
          title: 'Kanvas Aksara Jawa',
          subtitle: 'Gambar aksara Jawa dengan jarimu',
          accentColor: AppColors.mallardish,
          onTap: () => _pushGame(context, const KanvasAksaraGame()),
        ),
        const SizedBox(height: 14),
        _GameCard(
          icon: Icons.grid_on_rounded,
          title: 'TTS Jawa',
          subtitle: 'Teka-teki silang budaya Jawa',
          accentColor: AppColors.rubyRed,
          onTap: () => _pushGame(context, const TtsJawaGame()),
        ),
        const SizedBox(height: 14),
        _GameCard(
          icon: Icons.compare_arrows_rounded,
          title: 'Cocokologi',
          subtitle: 'Cocokkan kata & makna budaya Jawa',
          accentColor: AppColors.goldVarnishBrown,
          onTap: () => _pushGame(context, const CocokologiGame()),
        ),
      ],
    );
  }
}

class _ScoreBanner extends StatelessWidget {
  const _ScoreBanner({this.mine});
  final GameScore? mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.potBlack, AppColors.mallardish],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.goldVarnishBrown.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.goldVarnishBrown,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selesaikan Tantangan Mini Games!',
                  style: AppTextStyles.titleSmall(color: Colors.white),
                ),
                const SizedBox(height: 4),
                mine != null
                    ? Row(
                        children: [
                          Text(
                            'Total poin kamu: ',
                            style: AppTextStyles.bodyMedium(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${mine!.totalScore}',
                            style: AppTextStyles.titleSmall(
                              color: AppColors.goldVarnishBrown,
                            ),
                          ),
                          Text(
                            ' poin',
                            style: AppTextStyles.bodyMedium(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '+${ScoreService.rewardPerGame} poin per game selesai',
                        style: AppTextStyles.bodyMedium(color: Colors.white70),
                      ),
              ],
            ),
          ),
          if (mine != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MiniScore(
                  icon: Icons.draw_rounded,
                  color: AppColors.mallardish,
                  pts: mine!.kanvasScore,
                ),
                const SizedBox(height: 2),
                _MiniScore(
                  icon: Icons.grid_on_rounded,
                  color: AppColors.rubyRed,
                  pts: mine!.ttsScore,
                ),
                const SizedBox(height: 2),
                _MiniScore(
                  icon: Icons.compare_arrows_rounded,
                  color: AppColors.goldVarnishBrown,
                  pts: mine!.cocokScore,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MiniScore extends StatelessWidget {
  const _MiniScore({
    required this.icon,
    required this.color,
    required this.pts,
  });
  final IconData icon;
  final Color color;
  final int pts;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text('$pts', style: AppTextStyles.labelSmall(color: Colors.white70)),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.potBlack.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall()),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTextStyles.bodyMedium()),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.coastalStorm,
            ),
          ],
        ),
      ),
    );
  }
}
