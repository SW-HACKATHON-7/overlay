import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            '모드를\n선택해주세요',
            style: HackerTonTypography.MainLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '원하는 모드를 선택해서 시작하세요',
            style: HackerTonTypography.MainSmall.copyWith(
              fontSize: 14,
              color: HackerTonColors.grey,
            ),
          ),
          const SizedBox(height: 60),
          Expanded(
            child: ModeSelectionItem(
              title: '대화 복기',
              description: '실시간 대화를 분석하고 피드백을 받아보세요',
              icon: Icons.chat_bubble_outline,
              isSelected: selectedIndex == 0,
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
                Future.delayed(const Duration(milliseconds: 300), () {
                  context.go('/verify');
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ModeSelectionItem(
              title: '대화 퀴즈',
              description: '다양한 상황에서 대화 연습을 해보세요',
              icon: Icons.quiz_outlined,
              isSelected: selectedIndex == 1,
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
                Future.delayed(const Duration(milliseconds: 300), () {
                  context.go('/choose_partner');
                });
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ModeSelectionItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeSelectionItem({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected ? HackerTonGradients.orangeToPink : null,
          color: isSelected ? null : HackerTonColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isSelected ? Colors.white : HackerTonColors.pink,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: HackerTonTypography.MainLarge.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: HackerTonTypography.MainSmall.copyWith(
                fontSize: 14,
                color: isSelected ? Colors.white : HackerTonColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
