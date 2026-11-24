import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/services/score_service.dart';
import 'package:jawakarsa/features/dolanan/widgets/gendhis_commentator.dart';

class TtsClue {
  const TtsClue({
    required this.answer,
    required this.clue,
    required this.hint,
    required this.direction,
    required this.row,
    required this.col,
    required this.number,
  });
  final String answer;
  final String clue;
  final String hint;
  final bool direction;
  final int row;
  final int col;
  final int number;
}

const List<List<TtsClue>> _allPuzzles = [
  [
    TtsClue(
      answer: 'WAYANG',
      clue: 'Seni pertunjukan boneka kulit Jawa',
      hint: 'Diakui UNESCO 2003',
      direction: true,
      row: 1,
      col: 1,
      number: 1,
    ),
    TtsClue(
      answer: 'BATIK',
      clue: 'Kain bermotif khas Jawa dengan lilin',
      hint: 'Ada motif Parang, Kawung, Truntum',
      direction: false,
      row: 0,
      col: 2,
      number: 2,
    ),
    TtsClue(
      answer: 'GAMELAN',
      clue: 'Ensemble musik tradisional Jawa',
      hint: 'Terdiri dari gong, kenong, bonang',
      direction: false,
      row: 1,
      col: 6,
      number: 3,
    ),
    TtsClue(
      answer: 'KERATON',
      clue: 'Istana raja-raja Jawa',
      hint: 'Terdapat di Yogyakarta dan Solo',
      direction: true,
      row: 7,
      col: 0,
      number: 4,
    ),
  ],
  [
    TtsClue(
      answer: 'GUDEG',
      clue: 'Makanan khas Yogyakarta dari nangka muda',
      hint: 'Dimasak berjam-jam hingga coklat',
      direction: true,
      row: 0,
      col: 0,
      number: 1,
    ),
    TtsClue(
      answer: 'DALANG',
      clue: 'Pemain utama pertunjukan wayang',
      hint: 'Menguasai ratusan karakter',
      direction: false,
      row: 0,
      col: 2,
      number: 2,
    ),
    TtsClue(
      answer: 'KRATON',
      clue: 'Sebutan lain istana Jawa',
      hint: 'Berasal dari kata "ratu"',
      direction: true,
      row: 3,
      col: 0,
      number: 3,
    ),
    TtsClue(
      answer: 'NGOKO',
      clue: 'Tingkatan bahasa Jawa yang paling akrab',
      hint: 'Digunakan antar teman sebaya',
      direction: true,
      row: 5,
      col: 1,
      number: 4,
    ),
  ],
  [
    TtsClue(
      answer: 'REBAB',
      clue: 'Alat musik gesek dalam gamelan',
      hint: 'Berbentuk seperti biola kecil',
      direction: true,
      row: 0,
      col: 0,
      number: 1,
    ),
    TtsClue(
      answer: 'BONANG',
      clue: 'Instrumen gong kecil berjajar dalam gamelan',
      hint: 'Dipukul dengan dua pemukul berlapis kain',
      direction: false,
      row: 0,
      col: 2,
      number: 2,
    ),
    TtsClue(
      answer: 'KRAMA',
      clue: 'Tingkatan bahasa Jawa yang halus/formal',
      hint: 'Digunakan kepada orang yang lebih tua',
      direction: true,
      row: 3,
      col: 0,
      number: 3,
    ),
    TtsClue(
      answer: 'JOGLO',
      clue: 'Rumah tradisional Jawa dengan atap tinggi',
      hint: 'Atapnya disebut tumpang sari',
      direction: true,
      row: 5,
      col: 0,
      number: 4,
    ),
  ],
  [
    TtsClue(
      answer: 'GENDHIS',
      clue: 'Kata Jawa untuk gula',
      hint: 'Digunakan dalam sebutan nama',
      direction: false,
      row: 0,
      col: 4,
      number: 1,
    ),
    TtsClue(
      answer: 'PRAHU',
      clue: 'Perahu tradisional Jawa',
      hint: 'Digunakan oleh nelayan pesisir',
      direction: false,
      row: 1,
      col: 2,
      number: 2,
    ),
    TtsClue(
      answer: 'PARANG',
      clue: 'Motif batik yang dulunya hanya untuk keraton',
      hint: 'Berbentuk garis diagonal menyambung',
      direction: true,
      row: 2,
      col: 0,
      number: 3,
    ),
    TtsClue(
      answer: 'LURIK',
      clue: 'Kain tenun bergaris khas Jawa',
      hint: 'Dikerjakan dengan alat tenun tradisional',
      direction: true,
      row: 5,
      col: 1,
      number: 4,
    ),
  ],
  [
    TtsClue(
      answer: 'LAKON',
      clue: 'Cerita dalam pertunjukan wayang',
      hint: 'Bisa dari Mahabharata atau Ramayana',
      direction: true,
      row: 0,
      col: 0,
      number: 1,
    ),
    TtsClue(
      answer: 'KENDANG',
      clue: 'Alat musik pukul pemimpin tempo gamelan',
      hint: 'Dimainkan dengan telapak tangan',
      direction: false,
      row: 0,
      col: 2,
      number: 2,
    ),
    TtsClue(
      answer: 'SENTHONG',
      clue: 'Ruang sakral di dalam rumah Jawa',
      hint: 'Dikaitkan dengan Dewi Sri',
      direction: true,
      row: 2,
      col: 0,
      number: 3,
    ),
    TtsClue(
      answer: 'DALANG',
      clue: 'Pemimpin pertunjukan wayang kulit',
      hint: 'Suaranya bisa puluhan karakter',
      direction: true,
      row: 4,
      col: 1,
      number: 4,
    ),
  ],
];

class TtsJawaGame extends StatefulWidget {
  const TtsJawaGame({super.key, this.initialPuzzleIndex});

  final int? initialPuzzleIndex;

  @visibleForTesting
  static List<List<TtsClue>> get debugPuzzles => _allPuzzles;

  @override
  State<TtsJawaGame> createState() => _TtsJawaGameState();
}

class _TtsJawaGameState extends State<TtsJawaGame> {
  late List<TtsClue> _clues;
  late List<List<String>> _grid;
  late List<List<String?>> _userGrid;
  late List<List<bool>> _correctGrid;
  final Set<int> _revealedHints = {};
  final Set<int> _solvedClues = {};
  int _score = 0;
  bool _gameOver = false;
  bool _finishingGame = false;
  int _selectedClueIdx = -1;
  final _gendhisKey = GlobalKey<GendhisCommentatorState>();
  Timer? _thinkTimer;
  Timer? _finishTimer;

  late int _gridRows;
  late int _gridCols;

  final _inputFocus = FocusNode();
  final _inputCtrl = TextEditingController();

  void _initInputController() {
    _inputCtrl.removeListener(_onInputChanged);
    _inputCtrl.text = ' ';
    _inputCtrl.selection = const TextSelection.collapsed(offset: 1);
    _inputCtrl.addListener(_onInputChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final rng = Random();
    final idx = widget.initialPuzzleIndex != null
        ? widget.initialPuzzleIndex!.clamp(0, _allPuzzles.length - 1)
        : rng.nextInt(_allPuzzles.length);
    _clues = List.from(_allPuzzles[idx]);
    _computeGridBounds();
    _buildGrid();
    _inputFocus.addListener(_onFocusChanged);
    _initInputController();
  }

  void _computeGridBounds() {
    int maxRow = 0;
    int maxCol = 0;
    for (final c in _clues) {
      if (c.direction) {
        maxRow = max(maxRow, c.row);
        maxCol = max(maxCol, c.col + c.answer.length - 1);
      } else {
        maxRow = max(maxRow, c.row + c.answer.length - 1);
        maxCol = max(maxCol, c.col);
      }
    }
    _gridRows = maxRow + 1;
    _gridCols = maxCol + 1;
  }

  void _buildGrid() {
    _grid = List.generate(_gridRows, (_) => List.filled(_gridCols, ''));
    _userGrid = List.generate(
      _gridRows,
      (_) => List<String?>.filled(_gridCols, null),
    );
    _correctGrid = List.generate(
      _gridRows,
      (_) => List.filled(_gridCols, false),
    );
    for (final clue in _clues) {
      for (int i = 0; i < clue.answer.length; i++) {
        final r = clue.direction ? clue.row : clue.row + i;
        final c = clue.direction ? clue.col + i : clue.col;
        if (r < _gridRows && c < _gridCols) _grid[r][c] = clue.answer[i];
      }
    }
  }

  @override
  void dispose() {
    _thinkTimer?.cancel();
    _finishTimer?.cancel();
    _inputFocus.removeListener(_onFocusChanged);
    _inputFocus.dispose();
    _inputCtrl.removeListener(_onInputChanged);
    _inputCtrl.dispose();
    super.dispose();
  }

  void _startThinkTimer() {
    _thinkTimer?.cancel();
    if (_gameOver || _finishingGame) return;
    _thinkTimer = Timer(const Duration(seconds: 12), () {
      if (!_gameOver && !_finishingGame && mounted) {
        _gendhisKey.currentState?.thinking();
      }
    });
  }

  void _onInputChanged() {
    final val = _inputCtrl.text;
    if (val.isEmpty) {
      _deleteLastLetter();
      _initInputController();
      return;
    }

    final cleaned = val
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (cleaned.isNotEmpty) {
      for (int i = 0; i < cleaned.length; i++) {
        _processLetter(cleaned[i].toUpperCase());
      }
    }
    _initInputController();
  }

  bool _isClueSolved(TtsClue clue) {
    for (int i = 0; i < clue.answer.length; i++) {
      final r = clue.direction ? clue.row : clue.row + i;
      final c = clue.direction ? clue.col + i : clue.col;
      if (r >= _gridRows || c >= _gridCols) return false;
      if (_userGrid[r][c] != _grid[r][c]) return false;
    }
    return true;
  }

  bool _isCellLockedBySolvedClue(int r, int c) {
    for (final solvedIdx in _solvedClues) {
      final cl = _clues[solvedIdx];
      for (int i = 0; i < cl.answer.length; i++) {
        final cr = cl.direction ? cl.row : cl.row + i;
        final cc = cl.direction ? cl.col + i : cl.col;
        if (cr == r && cc == c) return true;
      }
    }
    return false;
  }

  void _deleteLastLetter() {
    if (_selectedClueIdx < 0 ||
        _selectedClueIdx >= _clues.length ||
        _gameOver ||
        _finishingGame ||
        _solvedClues.contains(_selectedClueIdx)) {
      return;
    }
    final clue = _clues[_selectedClueIdx];

    for (int i = clue.answer.length - 1; i >= 0; i--) {
      final r = clue.direction ? clue.row : clue.row + i;
      final c = clue.direction ? clue.col + i : clue.col;
      if (r < _gridRows &&
          c < _gridCols &&
          _userGrid[r][c] != null &&
          !_isCellLockedBySolvedClue(r, c)) {
        setState(() {
          _userGrid[r][c] = null;
          _correctGrid[r][c] = false;
        });
        _thinkTimer?.cancel();
        _startThinkTimer();
        return;
      }
    }
  }

  void _processLetter(String letter) {
    if (_selectedClueIdx < 0 ||
        _selectedClueIdx >= _clues.length ||
        _gameOver ||
        _finishingGame ||
        _solvedClues.contains(_selectedClueIdx)) {
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(letter)) return;

    final clue = _clues[_selectedClueIdx];
    final charIdx = _nextEditableIdx(clue);
    if (charIdx >= clue.answer.length) return;

    final r = clue.direction ? clue.row : clue.row + charIdx;
    final c = clue.direction ? clue.col + charIdx : clue.col;
    if (r >= _gridRows || c >= _gridCols) return;

    setState(() {
      _userGrid[r][c] = letter;
      final correct = letter == _grid[r][c];
      _correctGrid[r][c] = correct;

      var newlySolvedAny = false;
      for (int i = 0; i < _clues.length; i++) {
        if (!_solvedClues.contains(i) && _isClueSolved(_clues[i])) {
          _solvedClues.add(i);
          _score += ScoreService.rewardPerGame;
          newlySolvedAny = true;
        }
      }

      if (newlySolvedAny) {
        _gendhisKey.currentState?.correct();
        _checkGameOver();
      } else if (!correct) {
        _gendhisKey.currentState?.wrong();
      }
    });

    if (!_finishingGame && !_gameOver) {
      _thinkTimer?.cancel();
      _startThinkTimer();
    }
  }

  int _nextEditableIdx(TtsClue clue) {
    for (int i = 0; i < clue.answer.length; i++) {
      final r = clue.direction ? clue.row : clue.row + i;
      final c = clue.direction ? clue.col + i : clue.col;
      if (r < _gridRows &&
          c < _gridCols &&
          (_userGrid[r][c] == null || !_correctGrid[r][c])) {
        return i;
      }
    }
    return clue.answer.length;
  }

  (int, int)? _nextEditableCellForSelected() {
    if (_selectedClueIdx < 0 ||
        _selectedClueIdx >= _clues.length ||
        _solvedClues.contains(_selectedClueIdx)) {
      return null;
    }
    final clue = _clues[_selectedClueIdx];
    final idx = _nextEditableIdx(clue);
    if (idx >= clue.answer.length) return null;
    final r = clue.direction ? clue.row : clue.row + idx;
    final c = clue.direction ? clue.col + idx : clue.col;
    if (r >= _gridRows || c >= _gridCols) return null;
    return (r, c);
  }

  void _checkGameOver() {
    if (_finishingGame) return;
    final allDone =
        _solvedClues.length == _clues.length && _clues.every(_isClueSolved);
    if (allDone) {
      _finishingGame = true;
      _thinkTimer?.cancel();
      _inputFocus.unfocus();
      _finishTimer?.cancel();
      _finishTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() => _gameOver = true);
        ScoreService.instance.submitScore(GameType.tts, _score);
        _gendhisKey.currentState?.completed(_score);
      });
    }
  }

  void _selectClue(int idx) {
    setState(() => _selectedClueIdx = idx);
    _inputFocus.requestFocus();
    _thinkTimer?.cancel();
    _startThinkTimer();
  }

  void _onCellTap(int r, int c) {
    final matching = <int>[];
    for (int i = 0; i < _clues.length; i++) {
      final cl = _clues[i];
      for (int j = 0; j < cl.answer.length; j++) {
        final cr = cl.direction ? cl.row : cl.row + j;
        final cc = cl.direction ? cl.col + j : cl.col;
        if (cr == r && cc == c) {
          matching.add(i);
          break;
        }
      }
    }
    if (matching.isEmpty) return;
    final currentPos = matching.indexOf(_selectedClueIdx);
    final nextClue = currentPos >= 0 && matching.length > 1
        ? matching[(currentPos + 1) % matching.length]
        : matching.first;
    _selectClue(nextClue);
  }

  void _toggleHint(int idx) => setState(() {
    if (_revealedHints.contains(idx)) {
      _revealedHints.remove(idx);
    } else {
      _revealedHints.add(idx);
    }
  });

  Map<String, int> _buildNumberMap() {
    final map = <String, int>{};
    for (final clue in _clues) {
      map['${clue.row},${clue.col}'] = clue.number;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final nextEditableCell = _nextEditableCellForSelected();

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                color: AppColors.coastalStorm.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.potBlack,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('TTS Jawa', style: AppTextStyles.titleSmall()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_score poin',
                style: AppTextStyles.labelLarge(
                  color: AppColors.goldVarnishBrown,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_gameOver)
            _GameOverScreen(score: _score, onBack: () => Navigator.pop(context))
          else ...[
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CrosswordGrid(
                    grid: _grid,
                    userGrid: _userGrid,
                    correctGrid: _correctGrid,
                    clues: _clues,
                    selectedClueIdx: _selectedClueIdx,
                    nextEditableCell: nextEditableCell,
                    numberMap: _buildNumberMap(),
                    gridRows: _gridRows,
                    gridCols: _gridCols,
                    onCellTap: _onCellTap,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Petunjuk:',
                          style: AppTextStyles.titleSmall(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _selectedClueIdx >= 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _deleteLastLetter,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.rubyRed.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.rubyRed.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.backspace_outlined,
                                      size: 14,
                                      color: AppColors.rubyRed,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Hapus',
                                      style: AppTextStyles.labelSmall(
                                        color: AppColors.rubyRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mallardish.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.keyboard_rounded,
                                    size: 14,
                                    color: AppColors.mallardish,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ketik',
                                    style: AppTextStyles.labelSmall(
                                      color: AppColors.mallardish,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._clues.asMap().entries.map((e) {
                    final i = e.key;
                    final cl = e.value;
                    return _ClueCard(
                      clue: cl,
                      selected: i == _selectedClueIdx,
                      solved: _solvedClues.contains(i),
                      hintRevealed: _revealedHints.contains(i),
                      onTap: () => _selectClue(i),
                      onHintTap: () => _toggleHint(i),
                    );
                  }),
                  if (_selectedClueIdx < 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.potBlack.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.coastalStorm.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 16,
                                color: AppColors.coastalStorm,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Ketuk kotak atau petunjuk untuk mulai',
                                  style: AppTextStyles.labelSmall(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              left: -200,
              top: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextField(
                  controller: _inputCtrl,
                  focusNode: _inputFocus,
                  autofocus: false,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  obscureText: false,
                  showCursor: false,
                  style: const TextStyle(
                    fontSize: 1,
                    color: Colors.transparent,
                    height: 0.01,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
          GendhisCommentator(key: _gendhisKey),
        ],
      ),
    );
  }
}

class _CrosswordGrid extends StatelessWidget {
  const _CrosswordGrid({
    required this.grid,
    required this.userGrid,
    required this.correctGrid,
    required this.clues,
    required this.selectedClueIdx,
    required this.nextEditableCell,
    required this.numberMap,
    required this.gridRows,
    required this.gridCols,
    required this.onCellTap,
  });

  final List<List<String>> grid;
  final List<List<String?>> userGrid;
  final List<List<bool>> correctGrid;
  final List<TtsClue> clues;
  final int selectedClueIdx;
  final (int, int)? nextEditableCell;
  final Map<String, int> numberMap;
  final int gridRows;
  final int gridCols;
  final void Function(int r, int c) onCellTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final innerMaxWidth = (constraints.maxWidth - 2.0).clamp(
          0.0,
          double.infinity,
        );
        final cellSize = (innerMaxWidth / gridCols)
            .clamp(0.0, 52.0)
            .floorToDouble();

        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.potBlack.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppColors.coastalStorm.withValues(alpha: 0.15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(gridRows, (r) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(gridCols, (c) {
                      final letter = grid[r][c];
                      final isEmpty = letter.isEmpty;
                      final userLetter = userGrid[r][c];
                      final isCorrect = correctGrid[r][c];
                      final cellNum = numberMap['$r,$c'];

                      bool isActive = false;
                      if (!isEmpty &&
                          selectedClueIdx >= 0 &&
                          selectedClueIdx < clues.length) {
                        final cl = clues[selectedClueIdx];
                        for (int i = 0; i < cl.answer.length; i++) {
                          final cr = cl.direction ? cl.row : cl.row + i;
                          final cc = cl.direction ? cl.col + i : cl.col;
                          if (cr == r && cc == c) isActive = true;
                        }
                      }
                      final isNextTarget =
                          !isEmpty &&
                          nextEditableCell != null &&
                          nextEditableCell!.$1 == r &&
                          nextEditableCell!.$2 == c;

                      return GestureDetector(
                        onTap: isEmpty ? null : () => onCellTap(r, c),
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: isEmpty
                                ? AppColors.potBlack.withValues(alpha: 0.82)
                                : isNextTarget
                                ? AppColors.goldVarnishBrown.withValues(
                                    alpha: 0.34,
                                  )
                                : isActive
                                ? AppColors.goldVarnishBrown.withValues(
                                    alpha: 0.2,
                                  )
                                : AppColors.surface,
                            border: Border.all(
                              color: isEmpty
                                  ? AppColors.potBlack.withValues(alpha: 0.5)
                                  : isActive
                                  ? AppColors.goldVarnishBrown.withValues(
                                      alpha: 0.7,
                                    )
                                  : AppColors.coastalStorm.withValues(
                                      alpha: 0.2,
                                    ),
                              width: isNextTarget ? 2.5 : (isActive ? 2 : 0.5),
                            ),
                          ),
                          child: isEmpty
                              ? null
                              : Stack(
                                  children: [
                                    if (cellNum != null)
                                      Positioned(
                                        top: 2,
                                        left: 3,
                                        child: Text(
                                          '$cellNum',
                                          style: TextStyle(
                                            fontSize: (cellSize * 0.22).clamp(
                                              6.0,
                                              12.0,
                                            ),
                                            color: AppColors.mallardish,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    Center(
                                      child: Text(
                                        userLetter ?? '',
                                        style: TextStyle(
                                          fontSize: (cellSize * 0.5).clamp(
                                            10.0,
                                            24.0,
                                          ),
                                          fontWeight: FontWeight.w700,
                                          color: isCorrect
                                              ? AppColors.mallardish
                                              : AppColors.rubyRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClueCard extends StatelessWidget {
  const _ClueCard({
    required this.clue,
    required this.selected,
    required this.solved,
    required this.hintRevealed,
    required this.onTap,
    required this.onHintTap,
  });
  final TtsClue clue;
  final bool selected;
  final bool solved;
  final bool hintRevealed;
  final VoidCallback onTap;
  final VoidCallback onHintTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.mallardish.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.mallardish.withValues(alpha: 0.6)
                : AppColors.coastalStorm.withValues(alpha: 0.2),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.mallardish
                        : AppColors.coastalStorm.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${clue.number}${clue.direction ? '→' : '↓'}',
                    style: AppTextStyles.labelSmall(
                      color: selected ? Colors.white : AppColors.coastalStorm,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '(${clue.answer.length} huruf) ${clue.clue}',
                    style: AppTextStyles.bodyMedium(
                      color: selected
                          ? AppColors.mallardish
                          : AppColors.potBlack,
                    ),
                  ),
                ),
                if (solved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mallardish.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.mallardish,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Benar',
                          style: AppTextStyles.labelSmall(
                            color: AppColors.mallardish,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onHintTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hintRevealed
                            ? AppColors.goldVarnishBrown.withValues(alpha: 0.15)
                            : AppColors.coastalStorm.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lightbulb_rounded,
                            size: 13,
                            color: hintRevealed
                                ? AppColors.goldVarnishBrown
                                : AppColors.coastalStorm,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Hint',
                            style: AppTextStyles.labelSmall(
                              color: hintRevealed
                                  ? AppColors.goldVarnishBrown
                                  : AppColors.coastalStorm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (!solved && hintRevealed) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldVarnishBrown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.goldVarnishBrown.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 14,
                      color: AppColors.goldVarnishBrown,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        clue.hint,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.goldVarnishBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
            const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.goldVarnishBrown,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text('TTS Selesai!', style: AppTextStyles.headlineMedium()),
            const SizedBox(height: 8),
            Text(
              'Total Skor: $score poin',
              style: AppTextStyles.titleMedium(
                color: AppColors.goldVarnishBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor sudah disimpan!',
              style: AppTextStyles.bodyMedium(),
              textAlign: TextAlign.center,
            ),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Kembali',
                  style: AppTextStyles.titleSmall(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
