import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiAnimation extends StatefulWidget {
  final bool isActive;
  final int numberOfParticles;
  
  const ConfettiAnimation({
    Key? key,
    required this.isActive,
    this.numberOfParticles = 50,
  }) : super(key: key);
  
  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  final math.Random _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _initializeParticles();
    
    if (widget.isActive) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initializeParticles();
      _controller.forward(from: 0);
    }
  }
  
  void _initializeParticles() {
    _particles = List.generate(widget.numberOfParticles, (index) {
      return ConfettiParticle(
        color: _getRandomColor(),
        startX: _random.nextDouble(),
        velocity: 0.3 + _random.nextDouble() * 0.7,
        rotation: _random.nextDouble() * 2 * math.pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 4,
        size: 8 + _random.nextDouble() * 8,
      );
    });
  }
  
  Color _getRandomColor() {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF3B82F6), // Blue
    ];
    return colors[_random.nextInt(colors.length)];
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
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double startX;
  final double velocity;
  final double rotation;
  final double rotationSpeed;
  final double size;
  
  ConfettiParticle({
    required this.color,
    required this.startX,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  
  ConfettiPainter({
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;
      
      final x = particle.startX * size.width;
      final y = progress * size.height * particle.velocity;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + (progress * particle.rotationSpeed * 2 * math.pi));
      
      // Draw confetti as small rectangles
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
