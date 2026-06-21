import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? _recordingPath;

  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      _recordingPath =
          '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav), path: _recordingPath!);
    }
  }

  Future<File?> stopRecording() async {
    if (_recordingPath == null) return null;
    final path = await _recorder.stop();
    return path != null ? File(path) : null;
  }

  Future<void> playAudio(File audioFile) async {
    await _player.play(DeviceFileSource(audioFile.path));
  }

  Future<void> playAudioUrl(String url) async {
    await _player.play(UrlSource(url));
  }

  Future<void> stopAudio() async {
    await _player.stop();
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
