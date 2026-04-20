import 'package:audioplayers/audioplayers.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final AudioPlayer _player = AudioPlayer();
  String? _lastEmergencyId;
  int?    _lastStepIndex;
  String? _lastLangCode;

  Future<void> init() async {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.defaultToSpeaker},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  /// Plays the pre-recorded MP3 for [emergencyId] step [stepIndex] (1-based)
  /// in the given [languageCode] ('en-US', 'he-IL', or 'ar-SA').
  Future<void> speak(
    String emergencyId,
    int stepIndex,
    String languageCode,
  ) async {
    _lastEmergencyId = emergencyId;
    _lastStepIndex   = stepIndex;
    _lastLangCode    = languageCode;

    final lang = _langFolder(languageCode);
    final path = 'audio/$lang/$emergencyId/step_$stepIndex.mp3';
    try {
      await _player.stop();
      await _player.play(AssetSource(path));
    } catch (_) {
      // Asset missing or playback failure — fail silently so the app
      // remains fully usable without audio.
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> repeat() async {
    if (_lastEmergencyId != null &&
        _lastStepIndex   != null &&
        _lastLangCode    != null) {
      await speak(_lastEmergencyId!, _lastStepIndex!, _lastLangCode!);
    }
  }

  /// Maps BCP-47 language code to the audio folder name.
  static String _langFolder(String languageCode) {
    switch (languageCode) {
      case 'ar-SA': return 'ar';
      case 'he-IL': return 'he';
      default:      return 'en';
    }
  }
}
