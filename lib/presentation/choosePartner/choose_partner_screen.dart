import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';

class ChoosePartnerScreen extends StatelessWidget {
  const ChoosePartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: HackerTonColors.grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 20),
          Text(
            '대화 상대를\n선택해주세요',
            style: HackerTonTypography.MainLarge.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '대화 상대에 따라 상황을 AI가 상세하게 분석해줍니다',
            style: HackerTonTypography.MainSmall.copyWith(
              fontSize: 14,
              color: HackerTonColors.grey,
            ),
          ),
          const SizedBox(height: 40),
          ConversationStyleItem(
            icon: SvgPicture.asset('assets/images/chat_icon.svg'),
            title: '직장 상사',
            description: '회사 직장 상사와 대화하는 상황',
          ),
          const SizedBox(height: 24),
          ConversationStyleItem(
            icon: SvgPicture.asset('assets/images/chat_icon.svg'),
            title: '직장 동료',
            description: '회사 직장 동료와 대화하는 상황',
          ),
          const SizedBox(height: 24),
          ConversationStyleItem(
            icon: SvgPicture.asset('assets/images/chat_icon.svg'),
            title: '부하 직원',
            description: '회사 부하 직원과 대화하는 상황',
          ),
          const SizedBox(height: 24),
          ConversationStyleItem(
            icon: SvgPicture.asset('assets/images/talk_icon.svg'),
            title: '친구',
            description: '친구와 대화하는 상황',
          ),
          const SizedBox(height: 24),
          ConversationStyleItem(
            icon: SvgPicture.asset('assets/images/heart_talk.svg'),
            title: '연인',
            description: '연인과 대화하는 상황',
          ),
        ],
      ),
    );
  }
}

class ConversationStyleItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;

  const ConversationStyleItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(color: HackerTonColors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: HackerTonTypography.MainLarge.copyWith(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: HackerTonTypography.MainSmall.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
