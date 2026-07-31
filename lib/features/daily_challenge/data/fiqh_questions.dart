class FiqhQuestion {
  final int id;
  final String category;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const FiqhQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

const List<FiqhQuestion> fiqhQuestions = [
  FiqhQuestion(
    id: 1,
    category: 'الطهارة',
    question: 'ما حكم الطهارة من الحدث قبل الصلاة؟',
    options: [
      'شرط لصحة الصلاة',
      'سنة مستحبة فقط',
      'مباحة وليست مطلوبة',
      'واجبة بعد الصلاة',
    ],
    correctAnswerIndex: 0,
    explanation:
        'الطهارة من الحدث شرط لصحة الصلاة، فلا تصح الصلاة بغير وضوء أو غسل عند وجود موجب ذلك.',
  ),
  FiqhQuestion(
    id: 2,
    category: 'أوقات الصلاة',
    question: 'متى يبدأ وقت صلاة الفجر؟',
    options: [
      'عند منتصف الليل',
      'عند طلوع الفجر الصادق',
      'بعد شروق الشمس',
      'عند الفجر الكاذب',
    ],
    correctAnswerIndex: 1,
    explanation:
        'يبدأ وقت الفجر بطلوع الفجر الصادق، وهو البياض المعترض في الأفق.',
  ),
  FiqhQuestion(
    id: 3,
    category: 'القضاء',
    question: 'من فاتته صلاة واجبة ثم تذكرها، ماذا يفعل؟',
    options: [
      'يتركها إذا خرج وقتها',
      'يصليها عندما يتذكرها',
      'ينتظر نفس وقتها من الغد',
      'يكتفي بالاستغفار فقط',
    ],
    correctAnswerIndex: 1,
    explanation:
        'من فاتته صلاة بعذر كالنوم أو النسيان فإنه يصليها إذا ذكرها، ولا يؤخرها بلا حاجة.',
  ),
  FiqhQuestion(
    id: 4,
    category: 'النية',
    question: 'أين محل النية في الصلاة؟',
    options: [
      'اللسان فقط',
      'القلب',
      'اليدين',
      'بعد السلام',
    ],
    correctAnswerIndex: 1,
    explanation:
        'محل النية القلب، والمقصود أن يعرف المصلي الصلاة التي يريد أداءها.',
  ),
  FiqhQuestion(
    id: 5,
    category: 'القبلة',
    question: 'ما حكم استقبال القبلة في الصلاة المفروضة مع القدرة؟',
    options: [
      'شرط لصحة الصلاة',
      'مستحب فقط',
      'لا علاقة له بالصلاة',
      'خاص بصلاة الجمعة',
    ],
    correctAnswerIndex: 0,
    explanation:
        'استقبال القبلة شرط لصحة الصلاة المفروضة مع القدرة والعلم، وتسقط القدرة عند العجز.',
  ),
  FiqhQuestion(
    id: 6,
    category: 'السجود',
    question: 'كم سجدة في كل ركعة من الصلاة؟',
    options: [
      'سجدة واحدة',
      'سجدتان',
      'ثلاث سجدات',
      'لا يوجد سجود في الركعة',
    ],
    correctAnswerIndex: 1,
    explanation:
        'في كل ركعة سجدتان، وهما من أركان الصلاة التي لا تصح الركعة بدونهما.',
  ),
  FiqhQuestion(
    id: 7,
    category: 'الجمعة',
    question: 'ما حكم الإنصات لخطبة الجمعة؟',
    options: [
      'مستحب لمن أراد فقط',
      'مطلوب، ويترك الكلام أثناء الخطبة',
      'الكلام أثناءها أفضل',
      'لا يشرع حضور الخطبة',
    ],
    correctAnswerIndex: 1,
    explanation:
        'ينبغي للمصلي الإنصات للخطبة وترك اللغو والكلام حتى ينتفع بالموعظة.',
  ),
  FiqhQuestion(
    id: 8,
    category: 'السفر',
    question: 'ما معنى قصر الصلاة في السفر؟',
    options: [
      'ترك الصلاة حتى الرجوع',
      'صلاة الصبح ركعة واحدة',
      'صلاة الرباعية ركعتين',
      'جمع كل الصلوات في صلاة واحدة',
    ],
    correctAnswerIndex: 2,
    explanation:
        'قصر الصلاة هو أداء الصلاة الرباعية ركعتين في السفر المعتبر، وهو رخصة للمسافر.',
  ),
];

FiqhQuestion questionForDate(DateTime date) {
  final startOfYear = DateTime(date.year);
  final dayOfYear = date.difference(startOfYear).inDays;
  return fiqhQuestions[dayOfYear % fiqhQuestions.length];
}
