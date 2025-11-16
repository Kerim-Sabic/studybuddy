import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../providers/course_provider.dart';
import '../widgets/add_course_dialog.dart';
import '../widgets/course_card.dart';

/// Screen for managing courses
class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      body: GradientBackground.primary(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'My Courses',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GlassIconButton(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AddCourseDialog(),
                        );
                      },
                      tooltip: 'Add Course',
                    ),
                  ],
                ),
              ),

              // Courses List
              Expanded(
                child: coursesAsync.when(
                  data: (courses) {
                    if (courses.isEmpty) {
                      return Center(
                        child: GlassCard(
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.school_rounded,
                                size: 64,
                                color: AppColors.primaryPurple,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Courses Yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add your first course to get started!',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              GlassButton(
                                label: 'Add Course',
                                icon: const Icon(Icons.add_rounded, color: Colors.white),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const AddCourseDialog(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return CourseCard(course: courses[index]);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (error, stack) => Center(
                    child: GlassCard(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.accentOrange),
                          const SizedBox(height: 16),
                          Text('Error: $error'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
