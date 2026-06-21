import 'package:flutter/material.dart';
import '../models/xp_result.dart';

void showXpNotification(BuildContext context, XpResult xp) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black38,
    builder: (_) => _XpDialog(xp: xp),
  );
}

class _XpDialog extends StatefulWidget {
  final XpResult xp;
  const _XpDialog({required this.xp});

  @override
  State<_XpDialog> createState() => _XpDialogState();
}

class _XpDialogState extends State<_XpDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _fade.value,
        child: Transform.scale(
          scale: _scale.value,
          child: child,
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 60, color: Colors.amber.shade600),
              const SizedBox(height: 12),
              Text(
                '+${widget.xp.xpEarned} XP',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              if (widget.xp.leveledUp) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: [Colors.amber, Colors.orange]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Level ${widget.xp.level}!',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text('Streak: ${widget.xp.streakDays} days',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (widget.xp.totalXp % 50) / 50.0,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.amber.shade600,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.xp.totalXp} / ${((widget.xp.totalXp ~/ 50) + 1) * 50} XP',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
