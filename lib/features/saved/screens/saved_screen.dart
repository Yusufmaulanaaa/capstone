import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../core/providers.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/lawyer_model.dart';
import '../../../shared/widgets/widgets.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  int _tab = 0; // 0 = Chats, 1 = Lawyers

  @override
  Widget build(BuildContext context) {
    final savedChats = ref.watch(savedChatsProvider);
    final savedLawyers = ref.watch(savedLawyersProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const HukumAppBar(title: AppStrings.saved),
          const SizedBox(height: 4),
          // Segmented control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SegmentedControl(
              labels: const [AppStrings.chats, AppStrings.lawyers],
              selected: _tab,
              onSelect: (i) => setState(() => _tab = i),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _tab == 0
                ? _ChatsList(chats: savedChats)
                : _LawyersList(lawyers: savedLawyers),
          ),
        ]),
      ),
    );
  }
}

class _ChatsList extends ConsumerWidget {
  final List<SavedChat> chats;
  const _ChatsList({required this.chats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (chats.isEmpty) {
      return _EmptyState(
        onAction: () => context.goNamed('home'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: chats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final chat = chats[i];
        return Dismissible(
          key: ValueKey(chat.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: C.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: C.white),
          ),
          onDismissed: (_) {
            ref.read(savedChatsProvider.notifier).remove(chat.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(AppStrings.removed),
                backgroundColor: C.ink,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: AppStrings.undo,
                  textColor: C.white,
                  onPressed: () {
                    ref.read(savedChatsProvider.notifier).add(chat);
                  },
                ),
              ),
            );
          },
          child: _ChatTile(chat: chat),
        );
      },
    );
  }
}

class _ChatTile extends StatelessWidget {
  final SavedChat chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: C.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 18, color: C.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                chat.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: C.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                chat.preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: C.gray),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('MMM d').format(chat.savedAt),
            style: const TextStyle(fontSize: 11, color: C.gray),
          ),
        ]),
      );
}

class _LawyersList extends ConsumerWidget {
  final List<LawyerModel> lawyers;
  const _LawyersList({required this.lawyers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lawyers.isEmpty) {
      return _EmptyState(
        onAction: () => context.goNamed('home'),
        message: 'Save lawyers to find them here.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: lawyers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final lawyer = lawyers[i];
        return Dismissible(
          key: ValueKey(lawyer.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: C.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: C.white),
          ),
          onDismissed: (_) {
            ref.read(savedLawyersProvider.notifier).remove(lawyer.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.removed),
                backgroundColor: C.ink,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: _LawyerTile(lawyer: lawyer),
        );
      },
    );
  }
}

class _LawyerTile extends StatelessWidget {
  final LawyerModel lawyer;
  const _LawyerTile({required this.lawyer});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.pushNamed(
          'lawyer',
          pathParameters: {'id': lawyer.id},
          extra: {'lawyer': lawyer},
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.line),
          ),
          child: Row(children: [
            Avatar(name: lawyer.name, url: lawyer.photo, size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lawyer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: C.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lawyer.role,
                      style: const TextStyle(fontSize: 12.5, color: C.gray),
                    ),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                lawyer.price,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: C.ink,
                ),
              ),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.star_rounded, size: 13, color: C.gold),
                const SizedBox(width: 3),
                Text(
                  lawyer.rating,
                  style: const TextStyle(fontSize: 12, color: C.gray),
                ),
              ]),
            ]),
          ]),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAction;
  final String? message;

  const _EmptyState({required this.onAction, this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.bookmark_border_rounded, size: 56, color: C.line),
            const SizedBox(height: 16),
            const Text(
              AppStrings.nothingSaved,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: C.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? AppStrings.nothingSavedSub,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: C.gray, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: BlackButton(
                label: AppStrings.startAChat,
                onTap: onAction,
              ),
            ),
          ]),
        ),
      );
}

class _SegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  const _SegmentedControl({
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.line),
        ),
        child: Row(
            children: List.generate(labels.length, (i) {
          final sel = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? C.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: sel ? C.white : C.gray,
                    ),
                  ),
                ),
              ),
            ),
          );
        })),
      );
}
