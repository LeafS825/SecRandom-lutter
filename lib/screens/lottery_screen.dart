import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/prize.dart';
import '../models/prize_pool.dart';
import '../models/lottery_record.dart';
import '../services/lottery_service.dart';

class LotteryScreen extends StatefulWidget {
  const LotteryScreen({super.key});

  @override
  State<LotteryScreen> createState() => _LotteryScreenState();
}

class _LotteryScreenState extends State<LotteryScreen> {
  final LotteryService _lotteryService = LotteryService();
  final Random _random = Random.secure();

  Timer? _timer;
  List<LotteryRecord> _displayedRecords = [];

  List<PrizePool> _prizePools = [];
  List<Prize> _prizes = [];
  
  PrizePool? _selectedPool;
  
  int _drawCount = 1;
  bool _isLoading = true;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final pools = await _lotteryService.loadPrizePools();
       
      if (mounted) {
        setState(() {
          _prizePools = pools;
          _isLoading = false;
          if (_prizePools.isNotEmpty) {
            _selectedPool = _prizePools.first;
          }
        });
        if (_selectedPool != null) {
          await _loadPrizes();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPrizes() async {
    if (_selectedPool == null) return;
    try {
      final prizes = await _lotteryService.loadPrizes(_selectedPool!.name);
      if (mounted) {
        setState(() {
          _prizes = prizes;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _prizes = [];
        });
      }
    }
  }

  int get _totalPrizeCount {
    if (_selectedPool == null) return 0;
    return _lotteryService.getPrizeTotalCount(_selectedPool!, _prizes);
  }

  int get _remainingPrizeCount {
    if (_selectedPool == null) return 0;
    return _lotteryService.getPrizeRemainingCount(_selectedPool!, _prizes);
  }

  void _startDraw() {
    if (_selectedPool == null || _drawCount <= 0) return;

    setState(() {
      _displayedRecords = [];
    });

    _startRollingAnimation();
  }

  void _startRollingAnimation() {
    if (_timer != null && _timer!.isActive) return;

    final pool = _selectedPool!;
    final availablePrizes = _lotteryService.getAvailablePrizes(pool, _prizes);

    if (availablePrizes.isEmpty) {
      return;
    }

    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final randomPrize = availablePrizes[_random.nextInt(availablePrizes.length)];
      if (mounted) {
        setState(() {
          _displayedRecords = [LotteryRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            poolName: pool.name,
            prizeName: randomPrize.name,
            drawTime: DateTime.now(),
            drawCount: _drawCount,
          )];
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _stopRollingAnimation();
        _finalizeDraw();
      }
    });
  }

  void _stopRollingAnimation() {
    _timer?.cancel();
    _timer = null;
  }

  void _finalizeDraw() async {
    if (_selectedPool == null) return;

    try {
      final pool = _selectedPool!;
      
      final prizes = _lotteryService.drawPrizes(_prizes, _drawCount, pool);
      final records = prizes.map((prize) => LotteryRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        poolName: pool.name,
        prizeName: prize.name,
        drawTime: DateTime.now(),
        drawCount: 1,
      )).toList();

      for (var record in records) {
        await _lotteryService.saveLotteryRecord(record);
      }

      if (mounted) {
        setState(() {
          _displayedRecords = records;
        });
      }
    } catch (e) {
    }
  }

  void _resetDraw() {
    if (_selectedPool == null) return;
    
    _lotteryService.resetDrawnRecords(_selectedPool!.name);
    
    if (mounted) {
      setState(() {
        _displayedRecords = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final isHeightConstrained = screenHeight < 400;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isWideScreen
              ? Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: isHeightConstrained ? 280 : 304,
                        top: 0,
                        bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: LotteryResultDisplay(
                            records: _displayedRecords,
                            isWideScreen: true,
                          ),
                        ),
                      ),
                      Positioned(
                        right: isHeightConstrained ? 0 : 24.0,
                        top: isHeightConstrained ? 0 : null,
                        bottom: isHeightConstrained ? 0 : 24.0,
                        child: Container(
                          height: isHeightConstrained ? double.infinity : null,
                          decoration: isHeightConstrained ? BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(-2, 0),
                              ),
                            ],
                          ) : null,
                          child: LotteryControlPanel(
                            prizePools: _prizePools,
                            selectedPool: _selectedPool,
                            drawCount: _drawCount,
                            totalPrizeCount: _totalPrizeCount,
                            remainingPrizeCount: _remainingPrizeCount,
                            onPoolChanged: (pool) async {
                              setState(() {
                                _selectedPool = pool;
                                _displayedRecords = [];
                              });
                              await _loadPrizes();
                            },
                            onDrawCountChanged: (count) {
                              setState(() {
                                _drawCount = count;
                              });
                            },
                            onStartDraw: _startDraw,
                            onResetDraw: _resetDraw,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LotteryResultDisplay(
                            records: _displayedRecords,
                            isWideScreen: false,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: LotteryControlPanel(
                          prizePools: _prizePools,
                          selectedPool: _selectedPool,
                          drawCount: _drawCount,
                          totalPrizeCount: _totalPrizeCount,
                          remainingPrizeCount: _remainingPrizeCount,
                          onPoolChanged: (pool) async {
                            setState(() {
                              _selectedPool = pool;
                              _displayedRecords = [];
                            });
                            await _loadPrizes();
                          },
                          onDrawCountChanged: (count) {
                            setState(() {
                              _drawCount = count;
                            });
                          },
                          onStartDraw: _startDraw,
                          onResetDraw: _resetDraw,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class LotteryResultDisplay extends StatelessWidget {
  final List<LotteryRecord>? records;
  final bool isWideScreen;

  const LotteryResultDisplay({
    super.key,
    required this.records,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: records == null || records!.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.card_giftcard_outlined,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '准备抽奖',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16.0,
                runSpacing: 16.0,
                children: records!.map((record) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      key: ValueKey<String>("${record.id}-${record.prizeName}"),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: isWideScreen ? 48 : 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            record.prizeName,
                            style: TextStyle(
                              fontSize: isWideScreen ? 48 : 36,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (record.studentName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              record.studentName!,
                              style: TextStyle(
                                fontSize: isWideScreen ? 20 : 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class LotteryControlPanel extends StatelessWidget {
  final List<PrizePool> prizePools;
  final PrizePool? selectedPool;
  final int drawCount;
  final int totalPrizeCount;
  final int remainingPrizeCount;
  final ValueChanged<PrizePool?> onPoolChanged;
  final ValueChanged<int> onDrawCountChanged;
  final VoidCallback onStartDraw;
  final VoidCallback onResetDraw;

  const LotteryControlPanel({
    super.key,
    required this.prizePools,
    required this.selectedPool,
    required this.drawCount,
    required this.totalPrizeCount,
    required this.remainingPrizeCount,
    required this.onPoolChanged,
    required this.onDrawCountChanged,
    required this.onStartDraw,
    required this.onResetDraw,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;
        final isHeightConstrained = screenHeight < 400;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isCompact ? 12 : 16)),
          color: Theme.of(context).cardColor,
          child: Container(
            width: isCompact ? null : 280,
            constraints: BoxConstraints(
              minWidth: isCompact ? 0 : 280,
              maxWidth: isCompact ? double.infinity : 320,
            ),
            padding: EdgeInsets.all(isCompact ? 8.0 : 20.0),
            child: _buildLayout(context, isCompact, isHeightConstrained),
          ),
        );
      },
    );
  }

  Widget _buildLayout(BuildContext context, bool isCompact, bool isHeightConstrained) {
    if (isHeightConstrained) {
      return _buildUltraCompactLayout(context);
    } else if (!isCompact) {
      return _buildNormalLayout(context);
    } else {
      return _buildCompactLayout(context);
    }
  }

  Widget _buildNormalLayout(BuildContext context) {
    final maxCount = totalPrizeCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: drawCount > 1 ? () => onDrawCountChanged(drawCount - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$drawCount',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton.filledTonal(
              onPressed: drawCount < maxCount ? () => onDrawCountChanged(drawCount + 1) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 20),

        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: onStartDraw,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF66CCFF),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('开始'),
          ),
        ),
        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: onResetDraw,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('重置'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[600],
            side: BorderSide(color: Colors.grey[400]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField<PrizePool>(
          value: selectedPool,
          decoration: InputDecoration(
            labelText: '奖池',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          items: prizePools.map((pool) {
            return DropdownMenuItem(
              value: pool,
              child: Text(pool.name),
            );
          }).toList(),
          onChanged: onPoolChanged,
        ),
        const SizedBox(height: 16),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            '总数: $totalPrizeCount | 剩余: $remainingPrizeCount',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    final maxCount = totalPrizeCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: drawCount > 1 ? () => onDrawCountChanged(drawCount - 1) : null,
              icon: const Icon(Icons.remove, size: 20),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$drawCount',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton.filledTonal(
              onPressed: drawCount < maxCount ? () => onDrawCountChanged(drawCount + 1) : null,
              icon: const Icon(Icons.add, size: 20),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 44,
          child: FilledButton(
            onPressed: onStartDraw,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF66CCFF),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('开始'),
          ),
        ),
        const SizedBox(height: 8),

        OutlinedButton.icon(
          onPressed: onResetDraw,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('重置'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[600],
            side: BorderSide(color: Colors.grey[400]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<PrizePool>(
          value: selectedPool,
          decoration: InputDecoration(
            labelText: '奖池',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          items: prizePools.map((pool) {
            return DropdownMenuItem(
              value: pool,
              child: Text(pool.name),
            );
          }).toList(),
          onChanged: onPoolChanged,
        ),
        const SizedBox(height: 12),

        const SizedBox(height: 12),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '总数: $totalPrizeCount | 剩余: $remainingPrizeCount',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildUltraCompactLayout(BuildContext context) {
    final maxCount = totalPrizeCount;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                onPressed: drawCount > 1 ? () => onDrawCountChanged(drawCount - 1) : null,
                icon: const Icon(Icons.remove, size: 18),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$drawCount',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton.filledTonal(
                onPressed: drawCount < maxCount ? () => onDrawCountChanged(drawCount + 1) : null,
                icon: const Icon(Icons.add, size: 18),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: onStartDraw,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF66CCFF),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('开始'),
            ),
          ),
          const SizedBox(height: 6),

          OutlinedButton.icon(
            onPressed: onResetDraw,
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('重置'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<PrizePool>(
            value: selectedPool,
            decoration: InputDecoration(
              labelText: '奖池',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              isDense: true,
              labelStyle: const TextStyle(fontSize: 11),
            ),
            items: prizePools.map((pool) {
              return DropdownMenuItem(
                value: pool,
                child: Text(pool.name),
              );
            }).toList(),
            onChanged: onPoolChanged,
          ),

          const SizedBox(height: 8),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              '总数: $totalPrizeCount | 剩余: $remainingPrizeCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
