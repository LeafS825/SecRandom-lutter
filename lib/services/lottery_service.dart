import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/prize.dart';
import '../models/prize_pool.dart';
import '../models/lottery_record.dart';
import '../models/student.dart';
import 'data_service.dart';

class LotteryService {
  static final LotteryService _instance = LotteryService._internal();
  factory LotteryService() => _instance;
  LotteryService._internal();

  final DataService _dataService = DataService();
  final Random _random = Random.secure();
  final Uuid _uuid = const Uuid();

  final Map<String, Map<String, int>> _drawnRecords = {};

  Future<void> savePrizePool(PrizePool pool) async {
    try {
      await _dataService.savePrizePoolData(pool.name, pool.toJson());
    } catch (e) {
      print('Error saving prize pool: $e');
      rethrow;
    }
  }

  Future<void> savePrizes(String poolName, List<Prize> prizes) async {
    try {
      final poolData = await _dataService.loadPrizePoolData(poolName);
      final updatedData = Map<String, dynamic>.from(poolData);
      updatedData['prizes'] = prizes.map((p) => p.toJson()).toList();
      await _dataService.savePrizePoolData(poolName, updatedData);
    } catch (e) {
      print('Error saving prizes: $e');
      rethrow;
    }
  }

  Future<void> deletePrizePool(String poolName) async {
    try {
      await _dataService.deletePrizePoolData(poolName);
      _drawnRecords.remove(poolName);
    } catch (e) {
      print('Error deleting prize pool: $e');
      rethrow;
    }
  }

  Future<List<PrizePool>> loadPrizePools() async {
    try {
      final pools = await _loadPrizePools();
      return pools;
    } catch (e) {
      print('Error loading prize pools: $e');
      return [];
    }
  }

  Future<PrizePool?> loadPrizePool(String poolName) async {
    try {
      final poolData = await _dataService.loadPrizePoolData(poolName);
      if (poolData.isEmpty) return null;
      return PrizePool.fromJson(poolData);
    } catch (e) {
      return null;
    }
  }

  Future<List<Prize>> loadPrizes(String poolName) async {
    try {
      final poolData = await _dataService.loadPrizePoolData(poolName);
      if (poolData.isEmpty) return [];
      
      final prizesData = poolData['prizes'] as List<dynamic>?;
      if (prizesData == null) return [];
      
      return prizesData
          .map((p) => Prize.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading prizes: $e');
      return [];
    }
  }

  Future<List<PrizePool>> _loadPrizePools() async {
    try {
      final poolsData = await _dataService.loadAllPrizePools();
      return poolsData
          .map((data) => PrizePool.fromJson(data))
          .toList();
    } catch (e) {
      print('Error loading prize pools: $e');
      return [];
    }
  }

  int getPrizeTotalCount(PrizePool pool, List<Prize> prizes) {
    if (pool.drawType == 1) {
      return prizes
          .where((p) => p.exist)
          .fold<int>(0, (sum, p) => sum + p.count);
    }
    return prizes.where((p) => p.exist).length;
  }

  int getPrizeRemainingCount(PrizePool pool, List<Prize> prizes) {
    if (pool.drawType == 1) {
      final drawnRecords = _drawnRecords[pool.name] ?? {};
      return prizes
          .where((p) => p.exist)
          .fold<int>(0, (sum, p) {
            final drawn = drawnRecords[p.name] ?? 0;
            final remaining = p.count - drawn;
            return sum + (remaining > 0 ? remaining : 0);
          });
    }
    return prizes.where((p) => p.exist).length;
  }

  List<Prize> getAvailablePrizes(PrizePool pool, List<Prize> prizes) {
    if (pool.drawType == 1) {
      final drawnRecords = _drawnRecords[pool.name] ?? {};
      return prizes
          .where((p) {
            if (!p.exist) return false;
            final drawn = drawnRecords[p.name] ?? 0;
            return drawn < p.count;
          }).toList();
    }
    return prizes.where((p) => p.exist).toList();
  }

  List<Prize> drawPrizes(List<Prize> prizes, int count, PrizePool pool) {
    if (count <= 0) return [];
    
    final availablePrizes = getAvailablePrizes(pool, prizes);
    if (availablePrizes.isEmpty) return [];
    
    final List<Prize> selectedPrizes = [];
    final List<Prize> candidates = List.from(availablePrizes);
    
    for (int i = 0; i < count && candidates.isNotEmpty; i++) {
      final prize = _selectPrizeByWeight(candidates);
      selectedPrizes.add(prize);
      
      if (pool.drawType == 1) {
        final drawnRecords = _drawnRecords[pool.name] ?? {};
        drawnRecords[prize.name] = (drawnRecords[prize.name] ?? 0) + 1;
        _drawnRecords[pool.name] = drawnRecords;
        
        if (drawnRecords[prize.name]! >= prize.count) {
          candidates.removeWhere((p) => p.name == prize.name);
        }
      } else if (pool.drawMode == 0) {
      } else {
        candidates.remove(prize);
      }
    }
    
    return selectedPrizes;
  }

  Prize _selectPrizeByWeight(List<Prize> prizes) {
    final totalWeight = prizes.fold<double>(0, (sum, p) => sum + p.weight);
    
    if (totalWeight <= 0) {
      return prizes[_random.nextInt(prizes.length)];
    }
    
    final randomValue = _random.nextDouble() * totalWeight;
    double cumulativeWeight = 0;
    
    for (var prize in prizes) {
      cumulativeWeight += prize.weight;
      if (randomValue <= cumulativeWeight) {
        return prize;
      }
    }
    
    return prizes.last;
  }

  Future<void> saveLotteryRecord(LotteryRecord record) async {
    try {
      await _dataService.addLotteryRecord(record);
    } catch (e) {
      print('Error saving lottery record: $e');
      rethrow;
    }
  }

  Future<List<LotteryRecord>> loadLotteryRecords({String? poolName}) async {
    try {
      final records = await _dataService.loadLotteryRecords();
      
      if (poolName != null) {
        return records.where((r) => r.poolName == poolName).toList();
      }
      
      return records;
    } catch (e) {
      print('Error loading lottery records: $e');
      return [];
    }
  }

  Future<void> clearLotteryRecords({String? poolName}) async {
    try {
      if (poolName != null) {
        await _dataService.clearLotteryRecords(poolName);
        _drawnRecords.remove(poolName);
      } else {
        await _dataService.clearAllLotteryRecords();
        _drawnRecords.clear();
      }
    } catch (e) {
      print('Error clearing lottery records: $e');
      rethrow;
    }
  }

  void resetDrawnRecords(String poolName) {
    _drawnRecords.remove(poolName);
  }

  List<LotteryRecord> drawPrizesWithStudents(
    List<Prize> prizes,
    PrizePool pool,
    List<Student> students,
    int count,
  ) {
    if (count <= 0) return [];
    
    final drawnPrizes = drawPrizes(prizes, count, pool);
    if (drawnPrizes.isEmpty) return [];
    
    final List<LotteryRecord> records = [];
    final shuffledStudents = List<Student>.from(students)..shuffle(_random);
    
    for (int i = 0; i < drawnPrizes.length; i++) {
      final prize = drawnPrizes[i];
      final student = i < shuffledStudents.length ? shuffledStudents[i] : null;
      
      final record = LotteryRecord(
        id: _uuid.v4(),
        poolName: pool.name,
        prizeName: prize.name,
        studentName: student?.name,
        groupName: student?.group,
        gender: student?.gender,
        drawTime: DateTime.now(),
        drawCount: 1,
      );
      
      records.add(record);
    }
    
    return records;
  }
}
