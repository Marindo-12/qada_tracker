import 'package:flutter/material.dart';

import '../design/design_tokens.dart';

class SetupNavBar extends StatelessWidget {
  final int step;
  final bool isLastStep, canContinue, canSubmit, saving;
  final VoidCallback onPrevious, onNext, onSubmit;

  const SetupNavBar({
    super.key,
    required this.step,
    required this.isLastStep,
    required this.canContinue,
    required this.canSubmit,
    required this.saving,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(
          children: [
            if (step > 0) ...[
              SizedBox(
                width: 52,
                height: 52,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(52, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SetupDS.radiusMd)),
                  ),
                  child: const Icon(Icons.arrow_back, size: 22),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                height: 52,
                child: isLastStep
                    ? ElevatedButton(
                        onPressed: canSubmit ? onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.25),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SetupDS.radiusMd)),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('اعتماد الخطة'),
                      )
                    : ElevatedButton(
                        onPressed: canContinue ? onNext : null,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.25),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SetupDS.radiusMd)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('التالي'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
