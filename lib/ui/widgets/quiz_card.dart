import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/quiz_question.dart';
import '../theme/app_theme.dart';

class QuizCard extends StatefulWidget {
  final QuizQuestion question;
  final int shakeTrigger;
  final Function(String) onOptionSelected;
  final int currentQuestionIndex;
  final int totalQuestions;

  const QuizCard({
    Key? key,
    required this.question,
    required this.shakeTrigger,
    required this.onOptionSelected,
    required this.currentQuestionIndex,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  String? _selectedOption;
  bool _isCorrectTapped = false;
  bool _lockInput = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent registers a wrong answer, run cartoon shake animation and play device haptics
    if (widget.shakeTrigger != oldWidget.shakeTrigger && widget.shakeTrigger > 0) {
      _shakeController.forward(from: 0.0);
      HapticFeedback.heavyImpact(); // Tactile confirmation on device
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleOptionTap(String optionText) {
    if (_lockInput) return;

    final isCorrect = optionText.trim().toLowerCase() ==
        widget.question.answer.trim().toLowerCase();

    setState(() {
      _selectedOption = optionText;
      _isCorrectTapped = isCorrect;
      _lockInput = true;
    });

    // Notify story buddy state provider
    widget.onOptionSelected(optionText);

    if (!isCorrect) {
      // If guessed wrong, shake and let them try again after the animation completes
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _selectedOption = null;
            _lockInput = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate the shake offset using TweenSequence for a classic bouncy screen-shake
    final Animation<double> offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 12.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 12.0, end: -12.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -12.0, end: 9.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 9.0, end: -9.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -9.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 6.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -6.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    final List<Color> optionColors = [
      const Color(0xFFFFADAD), // Soft Red
      const Color(0xFFCAFFBF), // Soft Green
      const Color(0xFF9BF6FF), // Soft Blue
      const Color(0xFFFFD6A5), // Soft Orange/Yellow
      const Color(0xFFFFC6FF), // Soft Pink
    ];

    double progress = widget.totalQuestions > 0 
        ? (widget.currentQuestionIndex) / widget.totalQuestions
        : 0.0;

    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(offsetAnimation.value, 0),
          child: child,
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge & Current Question Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "⚡ CHALLENGE TIME",
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    "Question ${widget.currentQuestionIndex + 1} of ${widget.totalQuestions}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Small rounded Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress == 0.0 ? 0.05 : progress, 
                  backgroundColor: AppTheme.optionBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 24),
              
              // Question Text
              Text(
                widget.question.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              
              // Options List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.question.options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final optionText = widget.question.options[index];
                  final isSelected = _selectedOption == optionText;
                  
                  final colorIndex = index % optionColors.length;
                  final Color baseColor = optionColors[colorIndex];

                  // Configure option card background and border based on selection feedback
                  Color containerColor = Colors.white;
                  Color borderColor = AppTheme.optionBorder;
                  double borderWidth = 2.0;

                  if (isSelected) {
                    borderWidth = 4.0;
                    if (_isCorrectTapped) {
                      containerColor = AppTheme.correctColor.withOpacity(0.15);
                      borderColor = AppTheme.correctColor;
                    } else {
                      containerColor = AppTheme.incorrectColor.withOpacity(0.15);
                      borderColor = AppTheme.incorrectColor;
                    }
                  }

                  return InkWell(
                    onTap: () => _handleOptionTap(optionText),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: borderColor,
                          width: borderWidth,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppTheme.textDark.withOpacity(0.1),
                              offset: const Offset(2, 2),
                              blurRadius: 0,
                            )
                          else
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Letter or Result Status Indicator Icon
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (_isCorrectTapped ? AppTheme.correctColor : AppTheme.incorrectColor)
                                  : baseColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.textDark, width: 2),
                            ),
                            child: Center(
                              child: isSelected
                                  ? Icon(
                                      _isCorrectTapped ? Icons.check_rounded : Icons.close_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : Text(
                                      String.fromCharCode(65 + index), 
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          
                          // Option Text
                          Expanded(
                            child: Text(
                              optionText,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textDark,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
