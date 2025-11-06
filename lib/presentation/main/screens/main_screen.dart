import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/main_logo.svg'),
            const SizedBox(height: 110),
            const SizedBox(height: 385, child: _CardList()),
          ],
        ),
      ),
    );
  }
}

class _CardList extends HookWidget {
  const _CardList({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = 292 + 30 - (screenWidth / 2) + (292 / 2) + 29.5;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(offset);
      });
      return null;
    }, []);

    return ListView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      children: [
        _MenuCard(
          color: HackerTonColors.orange,
          title: '대화 퀴즈',
          description: '답변 연습을 하여 실력을 향상합니다',
          buttonText: '퀴즈 풀러 가기',
          onPressed: () => context.go('/quiz'),
        ),
        const SizedBox(width: 30),
        _MenuCard(
          color: HackerTonColors.red,
          title: '대화 복기',
          description: '대화 내역을 분석하여 복기합니다',
          buttonText: '복기하기',
          onPressed: () {},
        ),
        const SizedBox(width: 30),
        _MenuCard(
          color: HackerTonColors.pink,
          title: '대화 도우미',
          description: '어떻게 답변하면 좋을지 서포트 해줍니다',
          buttonText: '도움 받기',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final Color color;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const _MenuCard({
    super.key,
    required this.color,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      height: 385,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 44),
      decoration: BoxDecoration(
        color: HackerTonColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/chat.svg', color: color),
          const SizedBox(height: 32),
          Text(title, style: HackerTonTypography.MainLarge),
          const SizedBox(height: 10),
          Text(
            description,
            style: HackerTonTypography.MainSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _MainButton(
            onPressed: onPressed,
            backGroundColor: color,
            content: buttonText,
          ),
        ],
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backGroundColor;
  final String content;

  const _MainButton({
    super.key,
    required this.onPressed,
    required this.backGroundColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(backGroundColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          minimumSize: WidgetStateProperty.all(Size(double.infinity, 52)),
          elevation: WidgetStateProperty.all(0),
        ),
        child: Text(
          content,
          style: HackerTonTypography.MainLarge.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
