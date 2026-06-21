import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';

class RecordButton extends StatefulWidget {
  final Function(File audioFile) onRecordingComplete;
  final bool disabled;

  const RecordButton({
    super.key,
    required this.onRecordingComplete,
    this.disabled = false,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => _startRecording(),
      onTapUp: widget.disabled ? null : (_) => _stopRecording(),
      onTapCancel: widget.disabled ? null : _stopRecording,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.disabled
              ? Colors.grey
              : (_isRecording ? Colors.red : Colors.blue),
          boxShadow: [
            if (_isRecording)
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 4,
              ),
          ],
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;
    setState(() => _isRecording = true);
    await context.read<AudioService>().startRecording();
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    setState(() => _isRecording = false);

    final audioFile = await context.read<AudioService>().stopRecording();
    if (audioFile != null) {
      widget.onRecordingComplete(audioFile);
    }
  }
}
