import 'package:flutter/material.dart';
import '../utils/constants.dart';

class QuizTimer extends StatefulWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final double size;
  
  const QuizTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.size = 80,
  });
  
  @override
  State<QuizTimer> createState() => _QuizTimerState();
}

class _QuizTimerState extends State<QuizTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void didUpdateWidget(QuizTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start pulsing when time is low
    if (widget.remainingSeconds <= 5 && widget.remainingSeconds > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  Color _getTimerColor() {
    final progress = widget.remainingSeconds / widget.totalSeconds;
    if (progress > 0.5) {
      return AppConstants.successColor;
    } else if (progress > 0.25) {
      return AppConstants.warningColor;
    } else {
      return AppConstants.errorColor;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = widget.remainingSeconds / widget.totalSeconds;
    final isLow = widget.remainingSeconds <= 5;
    final color = _getTimerColor();
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isLow ? _pulseAnimation.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: isLow ? 12 : 8,
                  spreadRadius: isLow ? 2 : 0,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ),
                ),
                
                // Animated progress indicator
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(begin: progress, end: progress),
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      );
                    },
                  ),
                ),
                
                // Time text with animation
                TweenAnimationBuilder<int>(
                  duration: const Duration(milliseconds: 300),
                  tween: IntTween(
                    begin: widget.remainingSeconds,
                    end: widget.remainingSeconds,
                  ),
                  builder: (context, value, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: widget.size * 0.35,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          'sec',
                          style: TextStyle(
                            fontSize: widget.size * 0.12,
                            fontWeight: FontWeight.w500,
                            color: color.withOpacity(0.7),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
