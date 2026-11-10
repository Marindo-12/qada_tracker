import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/course_models.dart';
import 'data/courses_data.dart';

/// Set to false to let learners open any lesson in a course freely.
const bool kSequentialLessons = true;

/// Holds and persists all course progress. Screens listen to it with
/// `ListenableBuilder(listenable: progress, ...)`.
class CourseProgress extends ChangeNotifier {
  static const _key = 'qada.courses.progress.v1';

  /// Share of correct answers needed to pass a lesson quiz.
  static const lessonPassRatio = 0.6;

  /// Share of correct answers needed to pass the final challenge.
  static const challengePassRatio = 0.7;

  static const pointsPerLessonAnswer = 5;

  final SharedPreferences _prefs;
  final Set<String> _lessons = {};
  final Set<String> _challenges = {};
  final Map<String, int> _best = {};
  int _points = 0;

  CourseProgress(this._prefs) {
    _restore();
  }

  // ── Persistence ──────────────────────────────────────────────────────────
  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      _lessons.addAll(((m['lessons'] as List?) ?? []).cast<String>());
      _challenges.addAll(((m['challenges'] as List?) ?? []).cast<String>());
      ((m['best'] as Map?) ?? {}).forEach((k, v) {
        _best[k as String] = (v as num).toInt();
      });
      _points = (m['points'] as num?)?.toInt() ?? 0;
    } catch (_) {
      // Corrupted data: start fresh rather than crash.
    }
  }

  Future<void> _save() {
    return _prefs.setString(
      _key,
      jsonEncode({
        'lessons': _lessons.toList(),
        'challenges': _challenges.toList(),
        'best': _best,
        'points': _points,
      }),
    );
  }

  // ── Queries ──────────────────────────────────────────────────────────────
  int get points => _points;

  String _lessonKey(Course c, Lesson l) => '${c.id}/${l.id}';

  bool isLessonDone(Course c, Lesson l) =>
      _lessons.contains(_lessonKey(c, l));

  int doneLessons(Course c) =>
      c.lessons.where((l) => isLessonDone(c, l)).length;

  bool allLessonsDone(Course c) =>
      c.lessons.isNotEmpty && doneLessons(c) == c.lessons.length;

  bool isCourseCompleted(Course c) => _challenges.contains(c.id);

  bool isLessonUnlocked(Course c, int index) {
    if (!kSequentialLessons || index == 0) return true;
    return isLessonDone(c, c.lessons[index - 1]);
  }

  bool isCourseUnlocked(int courseIndex) {
    if (courseIndex == 0) return true;
    return isCourseCompleted(courses[courseIndex - 1]);
  }

  int get completedCourses => courses.where(isCourseCompleted).length;

  /// Index of the first lesson not yet done, or null if all are done.
  int? nextLessonIndex(Course c) {
    final i = c.lessons.indexWhere((l) => !isLessonDone(c, l));
    return i == -1 ? null : i;
  }

  int bestChallengePoints(Course c) => _best['C:${c.id}'] ?? 0;

  // ── Mutations ────────────────────────────────────────────────────────────
  void _award(String key, int score) {
    final best = _best[key] ?? 0;
    if (score > best) {
      _points += score - best;
      _best[key] = score;
    }
  }

  Future<void> recordLesson({
    required Course course,
    required Lesson lesson,
    required int correct,
    required bool passed,
  }) async {
    _award('L:${_lessonKey(course, lesson)}', correct * pointsPerLessonAnswer);
    if (passed) _lessons.add(_lessonKey(course, lesson));
    notifyListeners();
    await _save();
  }

  Future<void> recordChallenge({
    required Course course,
    required int points,
    required bool passed,
  }) async {
    _award('C:${course.id}', points);
    if (passed) _challenges.add(course.id);
    notifyListeners();
    await _save();
  }
}