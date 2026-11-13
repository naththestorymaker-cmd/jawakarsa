import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/models/game_score.dart';
import 'package:jawakarsa/services/score_service.dart';
import 'package:jawakarsa/services/auth_service.dart';

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  @override
  void initState() {
    super.initState();
    ScoreService.instance.refreshLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.rubyRed,
      onRefresh: () => ScoreService.instance.refreshLeaderboard(),
      child: StreamBuilder<List<GameScore>>(
        stream: ScoreService.instance.leaderboardStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.rubyRed),
            );
          }

          final list = snap.data ?? [];

          if (list.isEmpty) {
            return _EmptyLeaderboard();
          }

          return _LeaderboardContent(list: list);
        },
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: AppColors.coastalStorm,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pemain',
                  style:
                      AppTextStyles.titleSmall(color: AppColors.coastalStorm),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mainkan game untuk masuk papan peringkat pameran!',
                  style: AppTextStyles.bodyMedium(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  const _LeaderboardContent({required this.list});
  final List<GameScore> list;

  void _showScoreDetail(BuildContext context, GameScore score, int rank) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.coastalStorm.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mallardish.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Text(
                        score.name[0].toUpperCase(),
                        style: AppTextStyles.titleLarge(
                            color: AppColors.mallardish),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(score.name, style: AppTextStyles.titleMedium()),
                        Text(
                          'Peringkat #$rank dari ${list.length} peserta',
                          style: AppTextStyles.labelSmall(
                              color: AppColors.coastalStorm),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          AppColors.goldVarnishBrown.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${score.totalScore} poin',
                      style: AppTextStyles.titleSmall(
                          color: AppColors.goldVarnishBrown),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _GameScoreItem(
                title: 'Kanvas Aksara',
                score: score.kanvasScore,
                icon: Icons.brush_rounded,
                color: AppColors.rubyRed,
              ),
              const SizedBox(height: 12),
              _GameScoreItem(
                title: 'Teka-Teki Silang Jawa',
                score: score.ttsScore,
                icon: Icons.grid_4x4_rounded,
                color: AppColors.mallardish,
              ),
              const SizedBox(height: 12),
              _GameScoreItem(
                title: 'Cocokologi Budaya',
                score: score.cocokScore,
                icon: Icons.extension_rounded,
                color: AppColors.goldVarnishBrown,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService.instance.getSavedUid(),
      builder: (context, uidSnap) {
        final myUid = uidSnap.data;
        final myRank = ScoreService.findRank(myUid, list);
        final myScore = myRank > 0 ? list[myRank - 1] : null;

        final top3 = list.take(3).toList();
        final rest = list.length > 3 ? list.sublist(3) : <GameScore>[];

        final isOnline = ScoreService.instance.isFirebaseReady;

        return Stack(
          children: [
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                myScore != null ? 100 : 24,
              ),
              children: [
                // Banner Informasi Pameran
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.coastalStorm.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOnline
                            ? Icons.cloud_done_rounded
                            : Icons.offline_pin_rounded,
                        size: 18,
                        color: isOnline
                            ? AppColors.mallardish
                            : AppColors.goldVarnishBrown,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isOnline
                              ? 'Peringkat Pameran Online (${list.length} Peserta)'
                              : 'Mode Pameran Lokal (${list.length} Peserta)',
                          style: AppTextStyles.labelSmall(
                              color: AppColors.potBlack),
                        ),
                      ),
                      Text(
                        'Tarik untuk refresh',
                        style: AppTextStyles.labelSmall(
                            color: AppColors.coastalStorm),
                      ),
                    ],
                  ),
                ),
                _Podium(
                  top3: top3,
                  myUid: myUid,
                  onTapSlot: (score, rank) =>
                      _showScoreDetail(context, score, rank),
                ),
                if (rest.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Peringkat Peserta Lainnya',
                    style: AppTextStyles.titleSmall(
                        color: AppColors.coastalStorm),
                  ),
                  const SizedBox(height: 12),
                  ...rest.asMap().entries.map((e) {
                    final rank = e.key + 4;
                    final score = e.value;
                    return InkWell(
                      onTap: () => _showScoreDetail(context, score, rank),
                      borderRadius: BorderRadius.circular(14),
                      child: _RankRow(
                        rank: rank,
                        score: score,
                        isMe: score.uid == myUid,
                      ),
                    );
                  }),
                ],
              ],
            ),

            // Sticky Bottom Bar: Peringkat Pemain Saat Ini
            if (myScore != null)
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(18),
                  shadowColor: AppColors.potBlack.withValues(alpha: 0.35),
                  color: AppColors.potBlack,
                  child: InkWell(
                    onTap: () => _showScoreDetail(context, myScore, myRank),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.goldVarnishBrown,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.goldVarnishBrown,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$myRank',
                              style: AppTextStyles.labelLarge(
                                      color: Colors.white)
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Peringkat Kamu (${myScore.name})',
                                  style: AppTextStyles.titleSmall(
                                      color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Ketuk untuk rincian skor game',
                                  style: AppTextStyles.labelSmall(
                                      color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${myScore.totalScore} poin',
                            style: AppTextStyles.titleMedium(
                                color: AppColors.goldVarnishBrown),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GameScoreItem extends StatelessWidget {
  const _GameScoreItem({
    required this.title,
    required this.score,
    required this.icon,
    required this.color,
  });

  final String title;
  final int score;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: AppTextStyles.bodyMedium()),
          ),
          Text(
            '$score poin',
            style: AppTextStyles.titleSmall(color: AppColors.potBlack),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({
    required this.top3,
    required this.myUid,
    required this.onTapSlot,
  });

  final List<GameScore> top3;
  final String? myUid;
  final void Function(GameScore score, int rank) onTapSlot;

  @override
  Widget build(BuildContext context) {
    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C241E), // Deep brown/black
            AppColors.potBlack,
            Color(0xFF1B2A26), // Mallardish dark undertone
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.goldVarnishBrown.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded,
                  color: AppColors.goldVarnishBrown, size: 20),
              const SizedBox(width: 8),
              Text(
                'TOP 3 PEMAIN TERBAIK',
                style: AppTextStyles.labelLarge(
                  color: AppColors.goldVarnishBrown,
                ).copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.stars_rounded,
                  color: AppColors.goldVarnishBrown, size: 20),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Juara 2 (Perak)
              Expanded(
                child: _PodiumSlot(
                  score: second,
                  rank: 2,
                  height: 90,
                  badgeGradient: const [
                    Color(0xFFB0BEC5),
                    Color(0xFF78909C),
                  ],
                  ringColor: const Color(0xFFCFD8DC),
                  isMe: second?.uid == myUid,
                  onTap: second != null ? () => onTapSlot(second, 2) : null,
                ),
              ),
              // Juara 1 (Emas - Menonjol di Tengah)
              Expanded(
                child: _PodiumSlot(
                  score: first,
                  rank: 1,
                  height: 125,
                  badgeGradient: const [
                    Color(0xFFFFD54F),
                    AppColors.goldVarnishBrown,
                  ],
                  ringColor: const Color(0xFFFFE082),
                  isMe: first?.uid == myUid,
                  showCrown: true,
                  avatarRadius: 32,
                  onTap: first != null ? () => onTapSlot(first, 1) : null,
                ),
              ),
              // Juara 3 (Perunggu)
              Expanded(
                child: _PodiumSlot(
                  score: third,
                  rank: 3,
                  height: 75,
                  badgeGradient: const [
                    Color(0xFFFF8A65),
                    AppColors.rubyRed,
                  ],
                  ringColor: const Color(0xFFFFAB91),
                  isMe: third?.uid == myUid,
                  onTap: third != null ? () => onTapSlot(third, 3) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.score,
    required this.rank,
    required this.height,
    required this.badgeGradient,
    required this.ringColor,
    required this.isMe,
    this.showCrown = false,
    this.avatarRadius = 26,
    this.onTap,
  });

  final GameScore? score;
  final int rank;
  final double height;
  final List<Color> badgeGradient;
  final Color ringColor;
  final bool isMe;
  final bool showCrown;
  final double avatarRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCrown)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldVarnishBrown.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFFFD54F),
                size: 26,
              ),
            )
          else
            const SizedBox(height: 14),
          // Avatar dengan glow ring
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: badgeGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badgeGradient.first.withValues(alpha: 0.45),
                      blurRadius: showCrown ? 12 : 6,
                      spreadRadius: showCrown ? 2 : 0,
                    ),
                  ],
                  border: Border.all(
                    color: isMe ? Colors.white : ringColor,
                    width: isMe ? 3 : 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    score != null && score!.name.isNotEmpty
                        ? score!.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: avatarRadius * 0.9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (isMe)
                Positioned(
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.rubyRed,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Text(
                      'KAMU',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              score?.name ?? '-',
              style: AppTextStyles.labelLarge(color: Colors.white)
                  .copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${score?.totalScore ?? 0} pt',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFE082),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Balok Podium
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  badgeGradient.first,
                  badgeGradient.last.withValues(alpha: 0.85),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: badgeGradient.last.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.score,
    required this.isMe,
  });

  final int rank;
  final GameScore score;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.goldVarnishBrown.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? AppColors.goldVarnishBrown
              : AppColors.coastalStorm.withValues(alpha: 0.16),
          width: isMe ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Badge Nomor Peringkat
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.goldVarnishBrown
                  : AppColors.coastalStorm.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isMe ? Colors.white : AppColors.potBlack,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isMe
                    ? [AppColors.goldVarnishBrown, AppColors.potBlack]
                    : [
                        AppColors.mallardish.withValues(alpha: 0.8),
                        AppColors.mallardish,
                      ],
              ),
            ),
            child: Center(
              child: Text(
                score.name.isNotEmpty ? score.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        score.name,
                        style: AppTextStyles.titleSmall().copyWith(
                          fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldVarnishBrown,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Kamu',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '3 Game Diselesaikan',
                  style: AppTextStyles.labelSmall(
                      color: AppColors.coastalStorm),
                ),
              ],
            ),
          ),
          // Skor Total Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldVarnishBrown.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${score.totalScore} poin',
              style: AppTextStyles.labelLarge(
                color: AppColors.goldVarnishBrown,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.coastalStorm,
          ),
        ],
      ),
    );
  }
}
