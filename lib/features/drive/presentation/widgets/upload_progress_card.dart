import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/drive_provider.dart';

class UploadProgressCard extends StatelessWidget {
  final List<UploadTask> tasks;
  const UploadProgressCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final active = tasks.where((t) => !t.isComplete && !t.hasError).toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: AppSpacing.allSM,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                '${AppText.uploadingN} ${active.length} ${AppText.uploadingFilesSuffix}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          ...active.map((task) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.fileName,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(task.progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.progress,
                        color: AppColors.primary,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
