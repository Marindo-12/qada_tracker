import 'package:flutter/material.dart';

// ─── Data ────────────────────────────────────────────────────────────────────

const List<Map<String, String>> kScholars = [
  {
    'name': 'ابن باز',
    'full': 'الإمام ابن باز — رحمه الله',
    'era': '١٣١٠ – ١٤٢٠ هـ',
    'initials': 'ابب',
    'text':
        '"من ترك الصلاة تهاوناً وكسلاً في سنوات ماضية ثم تاب إلى الله، فعليه أن يتوب توبة صادقة، ويقضي ما فاته من الصلوات حسب طاقته، وعليه الإكثار من النوافل والاستغفار لعل الله يتجاوز عنه."',
  },
  {
    'name': 'ابن عثيمين',
    'full': 'الإمام ابن عثيمين — رحمه الله',
    'era': '١٣٤٧ – ١٤٢١ هـ',
    'initials': 'ابع',
    'text':
        '"القضاء واجب في الجملة، والإنسان إذا ترك الصلاة في فترة من حياته ثم تاب، فإن من الاحتياط أن يقضيها، وأن يُكثر من التطوع ليجبر ما فات. والتوبة الصادقة مع الاجتهاد في القضاء مما يُرجى معه قبول الله."',
  },
  {
    'name': 'ابن تيمية',
    'full': 'شيخ الإسلام ابن تيمية — رحمه الله',
    'era': '٦٦١ – ٧٢٨ هـ',
    'initials': 'ابت',
    'text':
        '"من ترك الصلاة عمداً بلا عذر فإن التوبة واجبة عليه، ويقضي ما فاته عند جمهور العلماء. والتوبة لا تكون صادقة إلا مع العزم على عدم العودة، والمبادرة إلى تدارك ما مضى بالقضاء والعمل الصالح."',
  },
  {
    'name': 'الشافعي',
    'full': 'الإمام الشافعي — رحمه الله',
    'era': '١٥٠ – ٢٠٤ هـ',
    'initials': 'شف',
    'text':
        '"الصلاة دَين على المكلف، والدَّين لا يسقط بتأخيره، بل يجب على من فاتته صلوات أن يقضيها مرتبةً ما أمكن، أو غير مرتبة إن تعذّر الترتيب بكثرة الفائتات، ويُلازم القضاء حتى يستوفيه."',
  },
  {
    'name': 'مالك',
    'full': 'الإمام مالك — رحمه الله',
    'era': '٩٣ – ١٧٩ هـ',
    'initials': 'مل',
    'text':
        '"يقضي الفائتة وقتما ذكرها أو تمكّن، سواء في وقت الكراهة أو غيره، إذ إن الوقت قد ذهب وبقي الدَّين في الذمة، فيجب الوفاء به كسائر الديون."',
  },
];

const List<Map<String, String>> kDifferences = [
  {
    'position': 'الجمهور',
    'detail': 'الحنفية والمالكية والشافعية والحنابلة',
    'view':
        'القضاء واجب مطلقاً، سواء تركت الصلاة بعذر أو بغير عذر، وتبقى في ذمة المسلم حتى يؤديها. الصلاة دَين لا يسقط بمرور الزمن.',
    'ruling': 'واجب',
    'type': 'primary',
  },
  {
    'position': 'بعض المعاصرين',
    'detail': 'تفريق بين العمد والتهاون',
    'view':
        'من ترك الصلاة تهاوناً مع إقراره بوجوبها يُستحسن في حقه القضاء، وهو مختلف عمن جحد وجوبها أصلاً. التوبة شرط أساسي في الحالتين.',
    'ruling': 'مستحسن',
    'type': 'accent',
  },
  {
    'position': 'الشيخ الألباني',
    'detail': 'رحمه الله — ١٣٣٣–١٤٢٠ هـ',
    'view':
        'من ترك الصلاة عمداً يصعب قضاؤها لأن وقتها الخاص فات بلا عذر. الأصل في جبر ما فات هو التوبة والإكثار من النوافل، مع الإقرار بأن القضاء احتياطاً لا بأس به.',
    'ruling': 'توبة + نوافل',
    'type': 'secondary',
  },
];

const List<Map<String, String>> kAdviceSteps = [
  {
    'icon': 'scale',
    'title': 'لا تُثقِل نفسك بالعدد',
    'text':
        'كل صلاة تقضيها هي إزاحة لدَين من كاهلك، وقُربى مقبولة بإذن الله. ابدأ بما تستطيع ولا تنتظر الكمال.',
  },
  {
    'icon': 'check',
    'title': 'الثبات أهم من الكثرة',
    'text':
        '"قليل دائم خير من كثير منقطع" — واظب على وِرد يومي ثابت وإن كان يسيراً، فالمداومة هي سر التقدم.',
  },
  {
    'icon': 'heart',
    'title': 'اجمع بين العبادات',
    'text':
        'القضاء وحده لا يكفي — أضف إليه التوبة والاستغفار والإكثار من النوافل، فهذه مجتمعةً تُكمّل بعضها.',
  },
  {
    'icon': 'lightbulb',
    'title': 'لا تقنط من رحمة الله',
    'text':
        'الله يقبل التوبة عن عباده ما لم يغرغر أحدهم أو تطلع الشمس من مغربها. الرحمة أوسع من كل ذنب.',
  },
];

// ─── Theme helpers ────────────────────────────────────────────────────────────

extension _ThemeX on BuildContext {
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get surfaceVariant => Theme.of(this).colorScheme.surfaceVariant;
  TextTheme get tt => Theme.of(this).textTheme;
}

// ─── Main page ────────────────────────────────────────────────────────────────

enum GuideLayout { qa, article }

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  GuideLayout _layout = GuideLayout.qa;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'دليل القضاء',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildLayoutToggle(context),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _layout == GuideLayout.qa
                    ? QAView(key: const ValueKey('qa'))
                    : ArticleView(key: const ValueKey('article')),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'فهم الحكم الشرعي وأقوال العلماء في مسألة قضاء الصلوات الفائتة',
        textAlign: TextAlign.center,
        style: context.tt.bodySmall?.copyWith(
          color: context.onSurface.withOpacity(0.55),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildLayoutToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            label: 'سؤال وجواب',
            icon: Icons.format_list_bulleted_rounded,
            active: _layout == GuideLayout.qa,
            onTap: () => setState(() => _layout = GuideLayout.qa),
          ),
          _ToggleBtn(
            label: 'مقالة كاملة',
            icon: Icons.article_rounded,
            active: _layout == GuideLayout.article,
            onTap: () => setState(() => _layout = GuideLayout.article),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle button ────────────────────────────────────────────────────────────

class _ToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? context.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: active
              ? Border.all(color: primary.withOpacity(0.2))
              : Border.all(color: Colors.transparent),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: active ? primary : context.onSurface.withOpacity(0.45)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: active ? primary : context.onSurface.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Q&A View ─────────────────────────────────────────────────────────────────

class QAView extends StatelessWidget {
  const QAView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccordionItem(
          title: 'لماذا نقضي الصلوات الفائتة؟',
          child: _BodyText(
            text:
                'الصلاة فريضة واجبة على كل مسلم بالغ عاقل، وهي عماد الدين وثاني أركان الإسلام. من تركها متعمداً فقد ارتكب كبيرة عظيمة، ومن تركها بعذر وجب عليه قضاؤها متى زال العذر.\n\nأما من تركها تهاوناً أو جهلاً في سنوات مضت ثم تاب إلى الله وعاد إلى الصواب، فإن العلماء يتفقون على أن التوبة النصوحة واجبة، وأن ما فات يُدارَك بالقضاء والنية الصادقة والإكثار من النوافل والاستغفار.\n\nقضاء الصلاة ليس عقوبة، بل هو بابٌ من الرحمة يفتحه الله لعباده ليُصلِحوا ما مضى ويُكملوا ما نقص.',
          ),
        ),
        const SizedBox(height: 8),
        _AccordionItem(
          title: 'ما الحكم الشرعي للقضاء؟',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BodyText(
                text:
                    'ذهب جمهور العلماء من الحنفية والمالكية والشافعية والحنابلة إلى أن قضاء الصلاة الفائتة واجب، سواء فاتت بعذر أو بغيره.',
              ),
              const SizedBox(height: 12),
              _HadithBlock(
                text: 'من نسي صلاة أو نام عنها فكفارتها أن يصليها إذا ذكرها.',
                source: 'رواه البخاري ومسلم',
              ),
              const SizedBox(height: 12),
              const _BodyText(
                text:
                    'واستدلوا أيضاً بأن الصلاة دَين في ذمة المكلف لا يسقط بمضي الوقت، كما أن الديون المالية لا تسقط بتراكمها.\n\nوذهب بعض العلماء المعاصرين إلى التفريق بين من فاتته الصلاة بعذر ومن تركها عمداً، وإن كان الأحوط الأخذ بقول الجمهور والإقبال على القضاء.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _AccordionItem(
          title: 'ماذا قال العلماء في هذه المسألة؟',
          child: Column(
            children: kScholars
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ScholarCard(scholar: s, compact: true),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        _AccordionItem(
          title: 'هل يختلف العلماء في هذه المسألة؟',
          child: Column(
            children: kDifferences
                .map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DifferenceCard(data: d, showIndex: false),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        _AccordionItem(
          title: 'ما النصيحة لمن بدأ رحلة القضاء؟',
          child: Column(
            children: [
              ...kAdviceSteps.map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AdviceStep(step: step),
                ),
              ),
              _AyahBlock(
                text:
                    'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا ۚ إِنَّهُ هُوَ الْغَفُورُ الرَّحِيمُ',
                source: 'الزمر: ٥٣',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _FooterAyah(),
      ],
    );
  }
}

// ─── Article View ─────────────────────────────────────────────────────────────

class ArticleView extends StatelessWidget {
  const ArticleView({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1 — Why
        _ArticleSectionHeader(
            icon: Icons.help_outline_rounded,
            title: 'لماذا نقضي الصلوات الفائتة؟'),
        const SizedBox(height: 12),
        _withRightBorder(
          context,
          Column(
            children: [
              Row(
                children: [
                  _ConceptCard(
                      label: 'فريضة',
                      desc: 'الصلاة ثاني أركان الإسلام وعماد الدين'),
                  const SizedBox(width: 8),
                  _ConceptCard(
                      label: 'دَين',
                      desc: 'تبقى في الذمة ولا تسقط بمرور الزمن'),
                  const SizedBox(width: 8),
                  _ConceptCard(
                      label: 'رحمة',
                      desc: 'القضاء باب يفتحه الله لتدارك ما فات'),
                ],
              ),
              const SizedBox(height: 12),
              const _BodyText(
                text:
                    'الصلاة فريضة واجبة على كل مسلم بالغ عاقل. من تركها متعمداً فقد ارتكب كبيرة عظيمة، ومن تركها بعذر كالنوم أو النسيان وجب عليه قضاؤها متى زال العذر. أما من تركها تهاوناً أو جهلاً في سنوات مضت ثم تاب إلى الله، فإن جمهور العلماء يرون أن القضاء واجب عليه مع التوبة والاستغفار.\n\nقضاء الصلاة ليس عقوبة يُعاقَب بها، بل هو باب من الرحمة الإلهية يُتيح للإنسان أن يُصلح ما أفسده.',
              ),
              const SizedBox(height: 12),
              _QuoteBox(
                text:
                    '"مَثَلُ الصلواتِ الخمسِ كَمَثَلِ نَهَرٍ جارٍ عَلى بابِ أحدِكم، يَغْتَسِلُ مِنهُ كُلَّ يَوْمٍ خَمسَ مَرَّاتٍ"',
                source: 'رواه مسلم',
              ),
            ],
          ),
        ),

        _Divider(),

        // Section 2 — Ruling
        _ArticleSectionHeader(
            icon: Icons.balance_rounded, title: 'الحكم الشرعي للقضاء'),
        const SizedBox(height: 12),
        _withRightBorder(
          context,
          Column(
            children: [
              const _BodyText(
                text:
                    'ذهب جمهور العلماء من الحنفية والمالكية والشافعية والحنابلة إلى أن قضاء الصلاة الفائتة واجب مطلقاً، سواء فاتت بعذر مقبول كالنوم والنسيان، أو بغير عذر كالتهاون والإهمال.',
              ),
              const SizedBox(height: 12),
              _HadithBlock(
                text: 'من نسي صلاة أو نام عنها فكفارتها أن يصليها إذا ذكرها.',
                source:
                    'رواه البخاري ومسلم — وهو الدليل الرئيس على وجوب القضاء',
              ),
              const SizedBox(height: 12),
              const _BodyText(
                text:
                    'تعليل الجمهور: الصلاة دَين في ذمة المكلف، والدَّين لا يسقط بمرور الزمن ولا بتراكمه، كما أن الديون المالية لا تسقط بإهمال صاحبها. فكما تُقضى الديون المالية وإن كثرت، تُقضى الصلوات وإن تراكمت.',
              ),
            ],
          ),
        ),

        _Divider(),

        // Section 3 — Scholars
        _ArticleSectionHeader(
            icon: Icons.people_alt_rounded, title: 'أقوال كبار العلماء'),
        const SizedBox(height: 12),
        _withRightBorder(
          context,
          Column(
            children: [
              Text(
                'اتفق العلماء على مشروعية القضاء وتفاوتوا في التفاصيل — إليك مواقفهم بأصواتهم:',
                style: TextStyle(
                  fontSize: 13,
                  color: context.onSurface.withOpacity(0.55),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              ...kScholars.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ScholarCard(scholar: s, compact: false),
                ),
              ),
            ],
          ),
        ),

        _Divider(),

        // Section 4 — Differences
        _ArticleSectionHeader(
            icon: Icons.account_tree_rounded,
            title: 'الاختلاف العلمي — ثلاثة مواقف'),
        const SizedBox(height: 12),
        _withRightBorder(
          context,
          Column(
            children: [
              Text(
                'المسألة فيها خلاف بين العلماء يمكن تلخيصه في ثلاثة مواقف رئيسية:',
                style: TextStyle(
                  fontSize: 13,
                  color: context.onSurface.withOpacity(0.55),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              ...kDifferences.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DifferenceCard(
                          data: e.value, showIndex: true, index: e.key + 1),
                    ),
                  ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: context.onSurface.withOpacity(0.08)),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'خلاصة: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.primary,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text:
                            'الأحوط والأخذ بقول الجمهور أسلم، وهو ما توفره هذه الأداة — قضاء الصلوات يوماً بيوم مع التوبة والاستغفار.',
                        style: TextStyle(
                          color: context.onSurface.withOpacity(0.8),
                          fontSize: 13,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        _Divider(),

        // Section 5 — Advice
        _ArticleSectionHeader(
            icon: Icons.favorite_rounded, title: 'نصيحة لمن بدأ رحلة القضاء'),
        const SizedBox(height: 12),
        _withRightBorder(
          context,
          Column(
            children: [
              const _BodyText(
                text:
                    'إن كنت قد بدأت في قضاء صلواتك فاعلم أن هذه خطوة عظيمة تدل على صدق توبتك وحسن نيتك. إليك أربعة مبادئ تُعينك على الثبات:',
              ),
              const SizedBox(height: 12),
              ...kAdviceSteps.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child:
                          _AdviceCardArticle(step: e.value, index: e.key + 1),
                    ),
                  ),
              const SizedBox(height: 4),
              _AyahBlock(
                text:
                    'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا ۚ إِنَّهُ هُوَ الْغَفُورُ الرَّحِيمُ',
                source: 'الزمر: ٥٣',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _FooterAyah(),
      ],
    );
  }

  Widget _withRightBorder(BuildContext context, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right:
                BorderSide(color: context.primary.withOpacity(0.2), width: 2),
          ),
        ),
        padding: const EdgeInsets.only(right: 12),
        child: child,
      ),
    );
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────────────────────

class _AccordionItem extends StatefulWidget {
  final String title;
  final Widget child;

  const _AccordionItem({required this.title, required this.child});

  @override
  State<_AccordionItem> createState() => _AccordionItemState();
}

class _AccordionItemState extends State<_AccordionItem>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: context.onSurface.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          ),
          if (_open) ...[
            Divider(height: 1, color: context.onSurface.withOpacity(0.08)),
            FadeTransition(
              opacity: _fadeIn,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: widget.child,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArticleSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ArticleSectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: context.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: context.tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText({required this.text});

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs
          .map(
            (p) => Padding(
              padding: EdgeInsets.only(bottom: paragraphs.last == p ? 0 : 10),
              child: Text(
                p,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.9,
                  color: context.onSurface.withOpacity(0.88),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HadithBlock extends StatelessWidget {
  final String text;
  final String source;

  const _HadithBlock({required this.text, required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded,
                  size: 18, color: context.primary.withOpacity(0.5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 2,
                    color: context.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              source,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.onSurface.withOpacity(0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahBlock extends StatelessWidget {
  final String text;
  final String source;

  const _AyahBlock({required this.text, required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 2.2,
              color: context.onSurface.withOpacity(0.88),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            source,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteBox extends StatelessWidget {
  final String text;
  final String source;

  const _QuoteBox({required this.text, required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded,
              size: 18, color: context.primary.withOpacity(0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.9,
                    fontStyle: FontStyle.italic,
                    color: context.onSurface.withOpacity(0.88),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScholarCard extends StatelessWidget {
  final Map<String, String> scholar;
  final bool compact;

  const _ScholarCard({required this.scholar, required this.compact});

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primary.withOpacity(0.15),
                  child: Text(
                    scholar['initials']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scholar['full']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: primary,
                      ),
                    ),
                    Text(
                      scholar['era']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border(
                    right:
                        BorderSide(color: primary.withOpacity(0.3), width: 2)),
              ),
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                scholar['text']!,
                style: TextStyle(
                    fontSize: 13.5,
                    height: 1.9,
                    color: context.onSurface.withOpacity(0.85)),
              ),
            ),
          ] else ...[
            Text(
              scholar['full']!,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: primary),
            ),
            const SizedBox(height: 6),
            Text(
              scholar['text']!,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.9,
                  color: context.onSurface.withOpacity(0.85)),
            ),
          ],
        ],
      ),
    );
  }
}

class _DifferenceCard extends StatelessWidget {
  final Map<String, String> data;
  final bool showIndex;
  final int index;

  const _DifferenceCard(
      {required this.data, required this.showIndex, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final type = data['type']!;
    final Color bgColor;
    final Color borderColor;
    final Color badgeColor;
    final Color badgeTextColor;

    switch (type) {
      case 'primary':
        bgColor = context.primary.withOpacity(0.05);
        borderColor = context.primary.withOpacity(0.2);
        badgeColor = context.primary.withOpacity(0.1);
        badgeTextColor = context.primary;
      case 'accent':
        bgColor = const Color(0xFFF3E5F5);
        borderColor = const Color(0xFFCE93D8).withOpacity(0.5);
        badgeColor = const Color(0xFFE1BEE7);
        badgeTextColor = const Color(0xFF6A1B9A);
      default:
        bgColor = context.surfaceVariant.withOpacity(0.6);
        borderColor = context.onSurface.withOpacity(0.1);
        badgeColor = context.surfaceVariant;
        badgeTextColor = context.onSurface.withOpacity(0.7);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showIndex) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: context.surface.withOpacity(0.7),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: context.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['position']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.onSurface,
                      ),
                    ),
                    Text(
                      data['detail']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  data['ruling']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data['view']!,
            style: TextStyle(
              fontSize: 13,
              height: 1.8,
              color: context.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceStep extends StatelessWidget {
  final Map<String, String> step;

  const _AdviceStep({required this.step});

  IconData _icon(String key) {
    return switch (key) {
      'scale' => Icons.balance_rounded,
      'check' => Icons.check_circle_outline_rounded,
      'heart' => Icons.favorite_border_rounded,
      _ => Icons.lightbulb_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon(step['icon']!), size: 18, color: context.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step['title']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: context.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                step['text']!,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.8,
                  color: context.onSurface.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdviceCardArticle extends StatelessWidget {
  final Map<String, String> step;
  final int index;

  const _AdviceCardArticle({required this.step, required this.index});

  IconData _icon(String key) {
    return switch (key) {
      'scale' => Icons.balance_rounded,
      'check' => Icons.check_circle_outline_rounded,
      'heart' => Icons.favorite_border_rounded,
      _ => Icons.lightbulb_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(step['icon']!),
                    size: 18, color: context.primary),
              ),
              const SizedBox(height: 4),
              Text(
                '$index',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: context.primary.withOpacity(0.45),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: context.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['text']!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.8,
                      color: context.onSurface.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  final String label;
  final String desc;

  const _ConceptCard({required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: context.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.primary.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: context.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: context.onSurface.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: context.onSurface.withOpacity(0.1))),
          const SizedBox(width: 8),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: context.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: context.onSurface.withOpacity(0.1))),
        ],
      ),
    );
  }
}

class _FooterAyah extends StatelessWidget {
  const _FooterAyah();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '"وَاللَّهُ يَعْلَمُ مَا فِي قُلُوبِكُمْ ۚ وَكَانَ اللَّهُ عَلِيمًا حَلِيمًا"',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          height: 1.7,
          color: context.onSurface.withOpacity(0.38),
        ),
      ),
    );
  }
}
