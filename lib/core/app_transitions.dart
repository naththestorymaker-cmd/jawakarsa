import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shared page and tab transition tokens & builders for JawaKarsa.
///
/// Follows reduced-motion preferences via [MediaQuery.disableAnimationsOf]
/// and uses [RepaintBoundary] to keep complex painters and SVGs smooth at 60/120fps.
class AppTransitions {
  AppTransitions._();

  static const Duration tabDuration = Duration(milliseconds: 300);
  static const Duration routeForwardDuration = Duration(milliseconds: 340);
  static const Duration routeReverseDuration = Duration(milliseconds: 260);
  static const Duration splashFadeDuration = Duration(milliseconds: 450);

  /// Smooth horizontal slide + fade route for forward push navigation
  /// (e.g., entering mini-games or detail views).
  static Route<T> fadeSlideRoute<T>({
    required Widget page,
    Duration? duration,
    Duration? reverseDuration,
    Offset beginOffset = const Offset(0.06, 0.0),
    double beginScale = 0.98,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration ?? routeForwardDuration,
      reverseTransitionDuration: reverseDuration ?? routeReverseDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context)) {
          return child;
        }

        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final secondaryCurved = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
        );

        final slideIn = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(curved);

        final scaleIn = Tween<double>(
          begin: beginScale,
          end: 1.0,
        ).animate(curved);

        // Subtle parallax shift on underlying page when another route pushes on top
        final slideOut = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.03, 0.0),
        ).animate(secondaryCurved);

        return SlideTransition(
          position: slideOut,
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: slideIn,
              child: ScaleTransition(
                scale: scaleIn,
                child: RepaintBoundary(child: child),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Gentle cross-fade + subtle scale-up route for top-level replacements
  /// (e.g., Splash -> Personalization -> HomePage).
  static Route<T> fadeScaleRoute<T>({
    required Widget page,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration ?? splashFadeDuration,
      reverseTransitionDuration: routeReverseDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context)) {
          return child;
        }

        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final scale = Tween<double>(
          begin: 0.97,
          end: 1.0,
        ).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: scale,
            child: RepaintBoundary(child: child),
          ),
        );
      },
    );
  }

  /// Theme-level transitions builder applied across standard routes in MaterialApp.
  static PageTransitionsTheme get pageTransitionsTheme =>
      const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _SmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: _SmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: _SmoothPageTransitionsBuilder(),
        },
      );
}

class _SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const _SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final slideIn = Tween<Offset>(
      begin: const Offset(0.05, 0.0),
      end: Offset.zero,
    ).animate(curved);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: slideIn,
        child: RepaintBoundary(child: child),
      ),
    );
  }
}

/// Directional shared-axis transition builder for [AnimatedSwitcher] tab views.
///
/// Slides horizontally in the direction of tab navigation ([isForward])
/// with gentle opacity and scale easing, isolated with [RepaintBoundary].
class DirectionalTabSwitcher extends StatelessWidget {
  const DirectionalTabSwitcher({
    super.key,
    required this.currentIndex,
    required this.isForward,
    required this.child,
  });

  final int currentIndex;
  final bool isForward;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: reduceMotion ? Duration.zero : AppTransitions.tabDuration,
      reverseDuration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        if (reduceMotion) return child;

        final isIncoming = child.key == ValueKey<int>(currentIndex);
        final dx = isIncoming
            ? (isForward ? 0.045 : -0.045)
            : (isForward ? -0.025 : 0.025);

        final slide = Tween<Offset>(
          begin: Offset(dx, 0.0),
          end: Offset.zero,
        ).animate(animation);

        final scale = Tween<double>(
          begin: isIncoming ? 0.985 : 0.992,
          end: 1.0,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(
              scale: scale,
              child: RepaintBoundary(child: child),
            ),
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(currentIndex),
        child: child,
      ),
    );
  }
}

/// Lazy keep-alive tab switcher with smooth directional fade + slide transitions.
///
/// Each tab is built lazily on first visit and then kept mounted offstage with
/// [TickerMode] disabled when inactive. This eliminates rebuild/re-decode jank
/// on Chrome and mobile while preserving scroll position and form state.
class KeepAliveTabSwitcher extends StatefulWidget {
  const KeepAliveTabSwitcher({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    required this.itemBuilder,
    this.duration = const Duration(milliseconds: 240),
  });

  final int currentIndex;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration duration;

  @override
  State<KeepAliveTabSwitcher> createState() => _KeepAliveTabSwitcherState();
}

class _KeepAliveTabSwitcherState extends State<KeepAliveTabSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  late final Animation<double> _fadeOutAnim;
  late final List<bool> _activated;
  late int _activeIndex;
  int? _outgoingIndex;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.currentIndex;
    _activated = List<bool>.generate(
      widget.itemCount,
      (i) => i == _activeIndex,
    );
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && _outgoingIndex != null) {
          setState(() => _outgoingIndex = null);
        }
      });
    _curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fadeOutAnim = ReverseAnimation(_curved);
  }

  @override
  void didUpdateWidget(covariant KeepAliveTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _activeIndex) {
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      _isForward = widget.currentIndex > _activeIndex;
      _outgoingIndex = reduceMotion ? null : _activeIndex;
      _activeIndex = widget.currentIndex;
      _activated[_activeIndex] = true;

      if (reduceMotion) {
        _controller.value = 1.0;
      } else {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAnimating = _controller.isAnimating;

    return Stack(
      fit: StackFit.expand,
      children: List<Widget>.generate(widget.itemCount, (i) {
        if (!_activated[i]) {
          return const SizedBox.shrink();
        }

        final isActive = i == _activeIndex;
        final isOutgoing = i == _outgoingIndex;
        final isVisible = isActive || isOutgoing;

        Widget tabChild = widget.itemBuilder(context, i);

        if (isVisible && isAnimating) {
          final slideAnim = _curved.drive(
            Tween<Offset>(
              begin: Offset(
                isActive ? (_isForward ? 0.035 : -0.035) : 0.0,
                0.0,
              ),
              end: Offset(
                isActive ? 0.0 : (_isForward ? -0.02 : 0.02),
                0.0,
              ),
            ),
          );

          tabChild = FadeTransition(
            opacity: isActive ? _curved : _fadeOutAnim,
            child: SlideTransition(
              position: slideAnim,
              child: tabChild,
            ),
          );
        }

        return Offstage(
          offstage: !isVisible,
          child: TickerMode(
            enabled: isActive,
            child: IgnorePointer(
              ignoring: !isActive,
              child: RepaintBoundary(child: tabChild),
            ),
          ),
        );
      }),
    );
  }
}
