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
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get surfaceContainerHighest => Theme.of(this).colorScheme.surfaceContainerHighest;
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
                    ? const QAView(key: ValueKey('qa'))
                    : const ArticleView(key: ValueKey('article')),
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
          color: context.onSurface.withValues(alpha: 0.55),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildLayoutToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.onSurface.withValues(alpha: 0.08)),
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
              ? Border.all(color: primary.withValues(alpha: 0.2))
              : Border.all(color: Colors.transparent),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: active ? primary : context.onSurface.withValues(alpha: 0.45)),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.tt.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: active ? primary : context.onSurface.withValues(alpha: 0.45),
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
        const _AccordionItem(
          title: 'لماذا نقضي الصلوات الفائتة؟',
          child: _BodyText(
            text:
                'الصلاة فريضة واجبة على كل مسلم بالغ عاقل، وهي عماد الدين وثاني أركان الإسلام. من تركها متعمداً فقد ارتكب كبيرة عظيمة، ومن تركها بعذر وجب عليه قضاؤها متى زال العذر.\n\nأما من تركها تهاوناً أو جهلاً في سنوات مضت ثم تاب إلى الله وعاد إلى الصواب، فإن العلماء يتفقون على أن التوبة النصوحة واجبة، وأن ما فات يُدارَك بالقضاء والنية الصادقة والإكثار من النوافل والاستغفار.\n\nقضاء الصلاة ليس عقوبة، بل هو بابٌ من الرحمة يفتحه الله لعباده ليُصلِحوا ما مضى ويُكملوا ما نقص.',
          ),
        ),
        const SizedBox(height: 10),
        const _AccordionItem(
          title: 'ما الحكم الشرعي للقضاء؟',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BodyText(
                text:
                    'ذهب جمهور العلماء من الحنفية والمالكية والشافعية والحنابلة إلى أن قضاء الصلاة الفائتة واجب، سواء فاتت بعذر أو بغيره.',
              ),
              SizedBox(height: 12),
              _HadithBlock(
                text: 'من نسي صلاة أو نام عنها فكفارتها أن يصليها إذا ذكرها.',
                source: 'رواه البخاري ومسلم',
              ),
              SizedBox(height: 12),
              _BodyText(
                text:
                    'واستدلوا أيضاً بأن الصلاة دَين في ذمة المكلف لا يسقط بمضي الوقت، كما أن الديون المالية لا تسقط بتراكمها.\n\nوذهب بعض العلماء المعاصرين إلى التفريق بين من فاتته الصلاة بعذر ومن تركها عمداً، وإن كان الأحوط الأخذ بقول الجمهور والإقبال على القضاء.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
              const _AyahBlock(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1 — Why
        const _ArticleSectionHeader(
            icon: Icons.help_outline_rounded,
            title: 'لماذا نقضي الصلوات الفائتة؟'),
        const SizedBox(height: 10),
        const _ArticleCard(
          child: Column(
            children: [
              Row(
                children: [
                  _ConceptCard(
                      label: 'فريضة',
                      desc: 'الصلاة ثاني أركان الإسلام وعماد الدين'),
                  SizedBox(width: 8),
                  _ConceptCard(
                      label: 'دَين',
                      desc: 'تبقى في الذمة ولا تسقط بمرور الزمن'),
                  SizedBox(width: 8),
                  _ConceptCard(
                      label: 'رحمة',
                      desc: 'القضاء باب يفتحه الله لتدارك ما فات'),
                ],
              ),
              SizedBox(height: 12),
              _BodyText(
                text:
                    'الصلاة فريضة واجبة على كل مسلم بالغ عاقل. من تركها متعمداً فقد ارتكب كبيرة عظيمة، ومن تركها بعذر كالنوم أو النسيان وجب عليه قضاؤها متى زال العذر. أما من تركها تهاوناً أو جهلاً في سنوات مضت ثم تاب إلى الله، فإن جمهور العلماء يرون أن القضاء واجب عليه مع التوبة والاستغفار.\n\nقضاء الصلاة ليس عقوبة يُعاقَب بها، بل هو باب من الرحمة الإلهية يُتيح للإنسان أن يُصلح ما أفسده.',
              ),
              SizedBox(height: 12),
              _QuoteBox(
                text:
                    '"مَثَلُ الصلواتِ الخمسِ كَمَثَلِ نَهَرٍ جارٍ عَلى بابِ أحدِكم، يَغْتَسِلُ مِنهُ كُلَّ يَوْمٍ خَمسَ مَرَّاتٍ"',
                source: 'رواه مسلم',
              ),
            ],
          ),
        ),

        const _ArticleSectionDivider(),

        // Section 2 — Ruling
        const _ArticleSectionHeader(
            icon: Icons.balance_rounded, title: 'الحكم الشرعي للقضاء'),
        const SizedBox(height: 10),
        const _ArticleCard(
          child: Column(
            children: [
              _BodyText(
                text:
                    'ذهب جمهور العلماء من الحنفية والمالكية والشافعية والحنابلة إلى أن قضاء الصلاة الفائتة واجب مطلقاً، سواء فاتت بعذر مقبول كالنوم والنسيان، أو بغير عذر كالتهاون والإهمال.',
              ),
              SizedBox(height: 12),
              _HadithBlock(
                text: 'من نسي صلاة أو نام عنها فكفارتها أن يصليها إذا ذكرها.',
                source:
                    'رواه البخاري ومسلم — وهو الدليل الرئيس على وجوب القضاء',
              ),
              SizedBox(height: 12),
              _BodyText(
                text:
                    'تعليل الجمهور: الصلاة دَين في ذمة المكلف، والدَّين لا يسقط بمرور الزمن ولا بتراكمه، كما أن الديون المالية لا تسقط بإهمال صاحبها. فكما تُقضى الديون المالية وإن كثرت، تُقضى الصلوات وإن تراكمت.',
              ),
            ],
          ),
        ),

        const _ArticleSectionDivider(),

        // Section 3 — Scholars
        const _ArticleSectionHeader(
            icon: Icons.people_alt_rounded, title: 'أقوال كبار العلماء'),
        const SizedBox(height: 10),
        _ArticleCard(
          child: Column(
            children: [
              Text(
                'اتفق العلماء على مشروعية القضاء وتفاوتوا في التفاصيل — إليك مواقفهم بأصواتهم:',
                style: context.tt.bodySmall?.copyWith(
                  color: context.onSurface.withValues(alpha: 0.55),
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

        const _ArticleSectionDivider(),

        // Section 4 — Differences
        const _ArticleSectionHeader(
            icon: Icons.account_tree_rounded,
            title: 'الاختلاف العلمي — ثلاثة مواقف'),
        const SizedBox(height: 10),
        _ArticleCard(
          child: Column(
            children: [
              Text(
                'المسألة فيها خلاف بين العلماء يمكن تلخيصه في ثلاثة مواقف رئيسية:',
                style: context.tt.bodySmall?.copyWith(
                  color: context.onSurface.withValues(alpha: 0.55),
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
                  color: context.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: context.onSurface.withValues(alpha: 0.08)),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'خلاصة: ',
                        style: context.tt.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primary,
                        ),
                      ),
                      TextSpan(
                        text:
                            'الأحوط والأخذ بقول الجمهور أسلم، وهو ما توفره هذه الأداة — قضاء الصلوات يوماً بيوم مع التوبة والاستغفار.',
                        style: context.tt.bodySmall?.copyWith(
                          color: context.onSurface.withValues(alpha: 0.8),
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

        const _ArticleSectionDivider(),

        // Section 5 — Advice
        const _ArticleSectionHeader(
            icon: Icons.favorite_rounded, title: 'نصيحة لمن بدأ رحلة القضاء'),
        const SizedBox(height: 10),
        _ArticleCard(
          child: Column(
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
              const _AyahBlock(
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

// ─── NEW: Article Card — white/surface background for each section ─────────────

class _ArticleCard extends StatelessWidget {
  final Widget child;

  const _ArticleCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final onSurface = context.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: onSurface.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _withRightBorder(
        context,
        child,
      ),
    );
  }

  Widget _withRightBorder(BuildContext context, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: context.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.only(right: 12),
        child: child,
      ),
    );
  }
}

class _ArticleSectionDivider extends StatelessWidget {
  const _ArticleSectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: context.onSurface.withValues(alpha: 0.08),
              thickness: 1,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: context.onSurface.withValues(alpha: 0.08),
              thickness: 1,
            ),
          ),
        ],
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

class _AccordionItemState extends State<_AccordionItem> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    final onSurface = context.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _open
              ? primary.withValues(alpha: 0.18)
              : onSurface.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _open ? 0.06 : 0.03),
            blurRadius: _open ? 10 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: _open ? primary.withValues(alpha: 0.04) : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: context.tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurface.withValues(alpha: 0.95),
                          height: 1.4,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _open
                              ? primary.withValues(alpha: 0.1)
                              : onSurface.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: _open
                              ? primary
                              : onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    height: 1,
                    indent: 18,
                    endIndent: 18,
                    color: onSurface.withValues(alpha: 0.06),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: widget.child,
                  ),
                ],
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
              firstCurve: Curves.easeInCubic,
              secondCurve: Curves.easeOutCubic,
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
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
            color: context.primary.withValues(alpha: 0.1),
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
                style: context.tt.bodyMedium?.copyWith(
                  height: 1.8,
                  color: context.onSurface.withValues(alpha: 0.88),
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
        color: context.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded,
                  size: 18, color: context.primary.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: context.tt.bodyMedium?.copyWith(
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
              style: context.tt.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.onSurface.withValues(alpha: 0.45),
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
        color: context.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: context.tt.bodyMedium?.copyWith(
              height: 2.2,
              color: context.onSurface.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            source,
            style: context.tt.bodySmall?.copyWith(
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
        color: context.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded,
              size: 18, color: context.primary.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: context.tt.bodyMedium?.copyWith(
                    height: 1.8,
                    fontStyle: FontStyle.italic,
                    color: context.onSurface.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: context.tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.onSurface.withValues(alpha: 0.45),
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
        color: primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primary.withValues(alpha: 0.15),
                  child: Text(
                    scholar['initials']!,
                    style: context.tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scholar['full']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.tt.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      Text(
                        scholar['era']!,
                        style: context.tt.labelSmall?.copyWith(
                          color: context.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border(
                    right:
                        BorderSide(color: primary.withValues(alpha: 0.3), width: 2)),
              ),
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                scholar['text']!,
                style: context.tt.bodyMedium?.copyWith(
                    height: 1.9,
                    color: context.onSurface.withValues(alpha: 0.85)),
              ),
            ),
          ] else ...[
            Text(
              scholar['full']!,
              style: context.tt.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: primary),
            ),
            const SizedBox(height: 6),
            Text(
              scholar['text']!,
              style: context.tt.bodyMedium?.copyWith(
                  height: 1.9,
                  color: context.onSurface.withValues(alpha: 0.85)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor;
    final Color borderColor;
    final Color badgeColor;
    final Color badgeTextColor;

    switch (type) {
      case 'primary':
        bgColor = context.primary.withValues(alpha: 0.05);
        borderColor = context.primary.withValues(alpha: 0.2);
        badgeColor = context.primary.withValues(alpha: 0.1);
        badgeTextColor = context.primary;
      case 'accent':
        bgColor = isDark
            ? context.primary.withValues(alpha: 0.08)
            : const Color(0xFFF3E5F5);
        borderColor = isDark
            ? context.primary.withValues(alpha: 0.3)
            : const Color(0xFFCE93D8).withValues(alpha: 0.5);
        badgeColor = isDark
            ? context.primary.withValues(alpha: 0.18)
            : const Color(0xFFE1BEE7);
        badgeTextColor = isDark ? context.primary : const Color(0xFF6A1B9A);
      default:
        bgColor = context.surfaceContainerHighest.withValues(alpha: 0.6);
        borderColor = context.onSurface.withValues(alpha: 0.1);
        badgeColor = context.surfaceContainerHighest;
        badgeTextColor = context.onSurface.withValues(alpha: 0.7);
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
                  backgroundColor: context.surface.withValues(alpha: 0.7),
                  child: Text(
                    '$index',
                    style: context.tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
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
                      style: context.tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.onSurface,
                      ),
                    ),
                    Text(
                      data['detail']!,
                      style: context.tt.labelSmall?.copyWith(
                        color: context.onSurface.withValues(alpha: 0.5),
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
                  style: context.tt.labelSmall?.copyWith(
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
            style: context.tt.bodyMedium?.copyWith(
              height: 1.8,
              color: context.onSurface.withValues(alpha: 0.8),
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
            color: context.primary.withValues(alpha: 0.1),
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
                style: context.tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                step['text']!,
                style: context.tt.bodyMedium?.copyWith(
                  height: 1.8,
                  color: context.onSurface.withValues(alpha: 0.75),
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
        border: Border.all(color: context.onSurface.withValues(alpha: 0.08)),
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
                  color: context.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(step['icon']!),
                    size: 18, color: context.primary),
              ),
              const SizedBox(height: 4),
              Text(
                '$index',
                style: context.tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primary.withValues(alpha: 0.45),
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
                    style: context.tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['text']!,
                    style: context.tt.bodyMedium?.copyWith(
                      height: 1.8,
                      color: context.onSurface.withValues(alpha: 0.75),
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
          color: context.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: context.tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: context.tt.bodySmall?.copyWith(
                height: 1.5,
                color: context.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
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
        style: context.tt.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          height: 1.7,
          color: context.onSurface.withValues(alpha: 0.38),
        ),
      ),
    );
  }
}