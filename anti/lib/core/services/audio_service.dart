import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

enum AudioPlaybackState {
  idle,
  playingAdhan,
  previewing,
  stopped,
  error,
}

class SoundOption {
  final String id;
  final String nameAr;
  final String assetPath;
  final String descriptionAr;
  final bool isFajrSpecific;

  const SoundOption({
    required this.id,
    required this.nameAr,
    required this.assetPath,
    required this.descriptionAr,
    this.isFajrSpecific = false,
  });
}

/// خدمة إدارة وتشغيل الصوت ومعاينة الأذان
class AppAudioService {
  static final AppAudioService _instance = AppAudioService._internal();
  factory AppAudioService() => _instance;
  AppAudioService._internal() {
    _init();
  }

  late final AudioPlayer _player;
  AudioPlaybackState _playbackState = AudioPlaybackState.idle;
  String? _currentlyPlayingId;
  String? _lastTriggeredPrayerKey;
  DateTime? _lastTriggeredTime;

  final _stateController = StreamController<AudioPlaybackState>.broadcast();
  Stream<AudioPlaybackState> get stateStream => _stateController.stream;
  AudioPlaybackState get playbackState => _playbackState;
  String? get currentlyPlayingId => _currentlyPlayingId;

  // قائمة الملفات الصوتية المرخصة والمتاحة داخل التطبيق
  static const List<SoundOption> availableSounds = [
    SoundOption(
      id: 'adhan_full_cairo',
      nameAr: 'أذان القاهرة ومصر (كامل)',
      assetPath: 'audio/adhan_cairo.mp3',
      descriptionAr: 'الأذان الكامل بالمقام المصري الخاشع',
    ),
    SoundOption(
      id: 'adhan_fajr_egypt',
      nameAr: 'أذان الفجر (الصلاة خير من النوم)',
      assetPath: 'audio/adhan_fajr.mp3',
      descriptionAr: 'أذان الفجر كامل مع ترتيل التثويب',
      isFajrSpecific: true,
    ),
    SoundOption(
      id: 'adhan_takbeer_short',
      nameAr: 'تكبيرات الأذان فقط (مختصر)',
      assetPath: 'audio/adhan_takbeer.mp3',
      descriptionAr: 'الله أكبر الله أكبر مرتين ثم التوحيد - مناسب للأماكن العامة',
    ),
    SoundOption(
      id: 'alert_calm_chime',
      nameAr: 'نغمة تنبيه هادئة',
      assetPath: 'audio/alert_chime.mp3',
      descriptionAr: 'رنة هادئة للتذكير بدخول الوقت',
    ),
  ];

  void _init() {
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _playbackState = AudioPlaybackState.idle;
        _currentlyPlayingId = null;
        _stateController.add(_playbackState);
      }
    });
  }

  /// تشغيل معاينة لصوت محدد
  Future<void> previewSound(String soundId) async {
    try {
      if (_playbackState == AudioPlaybackState.previewing && _currentlyPlayingId == soundId) {
        await stop();
        return;
      }

      await stop();
      final sound = availableSounds.firstWhere(
        (s) => s.id == soundId,
        orElse: () => availableSounds.first,
      );

      _playbackState = AudioPlaybackState.previewing;
      _currentlyPlayingId = soundId;
      _stateController.add(_playbackState);

      await _player.play(AssetSource(sound.assetPath));
    } catch (e) {
      _playbackState = AudioPlaybackState.error;
      _currentlyPlayingId = null;
      _stateController.add(_playbackState);
    }
  }

  /// تشغيل الأذان عند دخول وقت الصلاة
  /// مع منع التكرار لنفس الصلاة خلال نافذة 15 دقيقة
  Future<bool> playAdhanForPrayer(String prayerKey, {String? customSoundId}) async {
    final now = DateTime.now();

    // التحقق من منع التكرار
    if (_lastTriggeredPrayerKey == prayerKey && _lastTriggeredTime != null) {
      final diff = now.difference(_lastTriggeredTime!);
      if (diff.inMinutes < 15) {
        // تم تشغيل هذا الأذان بالفعل مؤخراً، تجاهل الطلب المكرر
        return false;
      }
    }

    try {
      await stop();

      final targetSoundId = customSoundId ?? 'adhan_full_cairo';
      final sound = availableSounds.firstWhere(
        (s) => s.id == targetSoundId,
        orElse: () => availableSounds.first,
      );

      _lastTriggeredPrayerKey = prayerKey;
      _lastTriggeredTime = now;
      _playbackState = AudioPlaybackState.playingAdhan;
      _currentlyPlayingId = targetSoundId;
      _stateController.add(_playbackState);

      await _player.play(AssetSource(sound.assetPath));
      return true;
    } catch (e) {
      _playbackState = AudioPlaybackState.error;
      _currentlyPlayingId = null;
      _stateController.add(_playbackState);
      return false;
    }
  }

  /// إيقاف أي تشغيل صوتي حالي فوراً
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _playbackState = AudioPlaybackState.stopped;
    _currentlyPlayingId = null;
    _stateController.add(_playbackState);
  }

  void dispose() {
    _player.dispose();
    _stateController.close();
  }
}
