import 'package:flutter/material.dart';

/// The kinds of content a lesson can be built from.
enum BlockType { heading, paragraph, points, evidence, example, note }

/// One building block of a lesson. Use the named constructors:
///
///   LessonBlock.heading('عنوان')
///   LessonBlock.paragraph('نص')
///   LessonBlock.points(['نقطة 1', 'نقطة 2'])
///   LessonBlock.evidence('﴿ آية ﴾', source: 'سورة ...')
///   LessonBlock.example('نص المسألة')
///   LessonBlock.note('تنبيه')
class LessonBlock {
  final BlockType type;
  final String title;
  final String text;
  final List<String> items;
  final String? source;

  const LessonBlock._(
    this.type, {
    this.title = '',
    this.text = '',
    this.items = const [],
    this.source,
  });

  const LessonBlock.heading(String text)
      : this._(BlockType.heading, text: text);

  const LessonBlock.paragraph(String text)
      : this._(BlockType.paragraph, text: text);

  const LessonBlock.points(List<String> items, {String title = ''})
      : this._(BlockType.points, items: items, title: title);

  const LessonBlock.evidence(String text, {required String source})
      : this._(BlockType.evidence, text: text, source: source);

  const LessonBlock.example(String text, {String title = 'مسألة تطبيقية'})
      : this._(BlockType.example, text: text, title: title);

  const LessonBlock.note(String text) : this._(BlockType.note, text: text);
}

class Lesson {
  final String id;
  final String title;
  final int minutes;
  final List<LessonBlock> blocks;

  /// Ids of questions (from fiqhQuestions or extraQuestions) used in this
  /// lesson's quiz.
  final List<int> quizIds;

  const Lesson({
    required this.id,
    required this.title,
    required this.minutes,
    required this.blocks,
    required this.quizIds,
  });
}

class Course {
  final String id;

  /// Must match [FiqhQuestion.category]; used to build the final challenge.
  final String category;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String? iconAsset;

  /// Cover image, e.g. 'assets/courses/tahara.jpg'. When null or missing,
  /// a gradient built from [accent] is shown instead.
  final String? coverAsset;
  final Color accent;
  final List<String> outcomes;
  final List<Lesson> lessons;

  const Course({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.iconAsset,
    required this.accent,
    this.coverAsset,
    this.outcomes = const [],
    this.lessons = const [],
  });

  /// A course with no lessons yet is shown as "قريباً".
  bool get comingSoon => lessons.isEmpty;

  int get totalMinutes => lessons.fold(0, (sum, l) => sum + l.minutes);
}