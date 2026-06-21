import 'package:flutter/material.dart';
import '../models/pronunciation_result.dart';

class PronunciationScoreCard extends StatefulWidget {
  final PronunciationResult result;

  const PronunciationScoreCard({super.key, required this.result});

  @override
  State<PronunciationScoreCard> createState() => _PronunciationScoreCardState();
}

class _PronunciationScoreCardState extends State<PronunciationScoreCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final scoreColor = r.overallScore >= 80
        ? Colors.green
        : r.overallScore >= 60
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.record_voice_over, size: 16, color: Colors.teal.shade700),
                const SizedBox(width: 6),
                Text('Pronunciation',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800)),
                const Spacer(),
                Text(
                  '${r.overallScore.round()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _ScoreBadge(label: 'Score', value: r.overallScore.round(), color: scoreColor),
                const SizedBox(width: 8),
                _ScoreBadge(label: 'Fluency', value: r.fluency.round(), color: Colors.blue),
              ],
            ),
            if (r.wordScores.any((w) => w.isMispronounced)) ...[
              const SizedBox(height: 6),
              Text(
                'Mispronounced words:',
                style: TextStyle(fontSize: 11, color: Colors.red.shade700),
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: r.wordScores
                    .where((w) => w.isMispronounced)
                    .map((w) => Chip(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          label: Text(w.word,
                              style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.red.shade100,
                        ))
                    .toList(),
              ),
            ],
            TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
              ),
              label: Text(
                _expanded ? 'Hide details' : 'Show details',
                style: const TextStyle(fontSize: 11),
              ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 4),
              ...r.phonemeScores.map((ps) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            ps.phoneme,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ps.score / 100,
                              backgroundColor: Colors.grey.shade200,
                              color: ps.isMispronounced ? Colors.red : Colors.green,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${ps.score.round()}',
                            style: TextStyle(
                              fontSize: 11,
                              color: ps.isMispronounced ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
