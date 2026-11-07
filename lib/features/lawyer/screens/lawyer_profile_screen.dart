import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../core/providers.dart';
import '../../../data/models/lawyer_model.dart';
import '../../../shared/widgets/widgets.dart';

class LawyerProfileScreen extends ConsumerWidget {
  final LawyerModel lawyer;
  const LawyerProfileScreen({super.key, required this.lawyer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedNotifier = ref.watch(savedLawyersProvider.notifier);
    final isSaved = savedNotifier.isSaved(lawyer.id);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HukumAppBar(
                  title: AppStrings.profile,
                  action: Semantics(
                    label: isSaved ? 'Remove from saved' : 'Save lawyer',
                    button: true,
                    child: CircleBtn(
                      icon: isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      onTap: () => savedNotifier.toggle(lawyer),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      Avatar(name: lawyer.name, url: lawyer.photo, size: 96),
                      const SizedBox(height: 14),
                      // Name + verified
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                lawyer.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: C.ink,
                                ),
                              ),
                            ),
                            if (lawyer.verified) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.verified_rounded,
                                  size: 20, color: C.gold),
                            ],
                          ]),
                      const SizedBox(height: 4),
                      Text(
                        lawyer.role,
                        style: const TextStyle(fontSize: 15, color: C.gray),
                      ),
                      const SizedBox(height: 4),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 15, color: C.gray),
                            const SizedBox(width: 4),
                            Text(
                              lawyer.city,
                              style:
                                  const TextStyle(fontSize: 13, color: C.gray),
                            ),
                          ]),
                      const SizedBox(height: 20),
                      // 3-column stat card
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: C.line),
                        ),
                        child: Row(children: [
                          _Stat(
                              label: AppStrings.rating,
                              value: '${lawyer.ratingNum} ⭐'),
                          const _Divider(),
                          _Stat(
                              label: AppStrings.experience, value: lawyer.exp),
                          const _Divider(),
                          _Stat(label: AppStrings.cases, value: lawyer.cases),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      // About
                      const _SectionHeader(AppStrings.about),
                      const SizedBox(height: 10),
                      Text(
                        lawyer.about,
                        style: const TextStyle(
                          fontSize: 14,
                          color: C.gray,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Practice areas
                      const _SectionHeader(AppStrings.practiceAreas),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final area in lawyer.practiceAreas)
                            _PracticeChip(area),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      // Reviews
                      const _SectionHeader(AppStrings.reviews),
                      const SizedBox(height: 10),
                      for (final r in lawyer.reviews) ...[
                        _ReviewCard(review: r),
                        const SizedBox(height: 10),
                      ],
                      // Space for sticky bottom
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Sticky bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: C.white,
                  border: Border(top: BorderSide(color: C.line)),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              lawyer.price,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: C.ink,
                              ),
                            ),
                          ),
                          const Text(
                            'per jam',
                            style: TextStyle(fontSize: 12, color: C.gray),
                          ),
                        ]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: BlackButton(
                      label: 'Booking',
                      onTap: () => context.pushNamed(
                        'book',
                        extra: {'lawyer': lawyer},
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: C.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(fontSize: 12, color: C.gray),
            ),
          ),
        ]),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: C.line,
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: C.ink,
          ),
        ),
      );
}

class _PracticeChip extends StatelessWidget {
  final String label;
  const _PracticeChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.line),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: C.ink),
        ),
      );
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Avatar(name: review.reviewer, url: review.photo, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: C.ink,
                      ),
                    ),
                    Text(
                      review.date,
                      style: const TextStyle(fontSize: 12, color: C.gray),
                    ),
                  ]),
            ),
            Row(
                children: List.generate(
              5,
              (i) => Icon(
                Icons.star_rounded,
                size: 14,
                color: i < review.stars.round() ? C.gold : C.line,
              ),
            )),
          ]),
          const SizedBox(height: 10),
          Text(
            review.text,
            style: const TextStyle(fontSize: 13, color: C.gray, height: 1.5),
          ),
        ]),
      );
}
