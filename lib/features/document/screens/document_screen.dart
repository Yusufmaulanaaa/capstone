import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../shared/widgets/widgets.dart';

const _sampleDocument = '''Dear Opposing Counsel,

Re: Formal Demand — Divorce & Custody Dispute

I am writing on behalf of my client in the above-captioned matter to formally communicate the following demands regarding the dissolution of marriage and custody arrangements:

1. CUSTODY ARRANGEMENT
My client respectfully requests primary physical custody of the minor children, with reasonable visitation rights for the opposing party in accordance with the best interests of the children standard under applicable family law statutes.

2. PROPERTY DIVISION
All marital assets, including but not limited to real estate holdings, bank accounts, retirement funds, and personal property, should be equitably divided pursuant to the community property principles of this jurisdiction.

3. SPOUSAL SUPPORT
Given the significant disparity in earning capacity, my client requests spousal support payments of a reasonable amount for a period to be determined by the court.

4. RESPONSE DEADLINE
Please respond to this formal demand within fourteen (14) days of the date of this letter. Failure to respond may result in immediate legal proceedings.

Yours faithfully,

[Attorney Name]
[Firm Name]
[Date]''';

class DocumentScreen extends StatefulWidget {
  final String topicTitle;
  const DocumentScreen({super.key, required this.topicTitle});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  bool _editing = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _sampleDocument);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            const HukumAppBar(title: AppStrings.aiLegalDocument),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: C.line),
                        ),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 14, color: C.gray),
                              SizedBox(width: 6),
                              Text(
                                AppStrings.aiGenerated,
                                style: TextStyle(fontSize: 12, color: C.gray),
                              ),
                            ]),
                      ),
                      const SizedBox(height: 14),
                      // Paper card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: C.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: C.line),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A0A0A0F),
                              blurRadius: 20,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: _editing
                            ? TextField(
                                controller: _ctrl,
                                maxLines: null,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: C.ink,
                                  height: 1.6,
                                  fontFamily: 'monospace',
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              )
                            : Text(
                                _ctrl.text,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: C.ink,
                                  height: 1.6,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      // Edit / Download buttons
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: C.ink,
                              side: const BorderSide(color: C.ink),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              minimumSize: const Size(0, 48),
                            ),
                            onPressed: () =>
                                setState(() => _editing = !_editing),
                            child: Text(
                              _editing ? AppStrings.done : AppStrings.edit,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: C.ink,
                              foregroundColor: C.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              minimumSize: const Size(0, 48),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(AppStrings.documentSaved),
                                  backgroundColor: C.ink,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download_rounded, size: 16),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      AppStrings.downloadPdf,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ]),
                    ]),
              ),
            ),
          ]),
        ),
      );
}
