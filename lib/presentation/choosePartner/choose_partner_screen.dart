import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hackerton/services/screenshot_service.dart';

class ChoosePartnerScreen extends StatefulWidget {
  const ChoosePartnerScreen({super.key});

  @override
  State<ChoosePartnerScreen> createState() => _ChoosePartnerScreenState();
}

class _ChoosePartnerScreenState extends State<ChoosePartnerScreen> {
  int? selectedIndex;
  bool isNavigating = false;

  Future<void> _startOverlay() async {
    // 오버레이 시작
    await FlutterOverlayWindow.showOverlay(
      alignment: OverlayAlignment.topCenter,
      enableDrag: false,
      overlayTitle: "대화 분석",
      overlayContent: "대화 분석이 필요해요",
      flag: OverlayFlag.focusPointer,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
      width: WindowSize.matchParent,
      height: 800,
      startPosition: const OverlayPosition(0, 0),
    );
  }

  void _handleItemTap(int index) async {
    if (isNavigating) return;

    setState(() {
      selectedIndex = index;
      isNavigating = true;
    });

    // 선택한 관계에 따라 퀴즈 화면으로 이동
    String relationship = '';
    switch (index) {
      case 0:
        relationship = '직장 상사';
        break;
      case 1:
        relationship = '직장 동료';
        break;
      case 2:
        relationship = '부하 직원';
        break;
      case 3:
        relationship = '친구';
        break;
      case 4:
        relationship = '연인';
        break;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      context.go('/quiz', extra: relationship);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: HackerTonColors.grey),
            onPressed: isNavigating ? null : () => Navigator.of(context).pop(),
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
            isSelected: selectedIndex == 0,
            isDisabled: isNavigating && selectedIndex != 0,
            onTap: () => _handleItemTap(0),
          ),
          const SizedBox(height: 24),
          ConversationStyleItem(
            icon: SvgPicture.asset('assets/images/chat_icon.svg'),
            title: '직장 동료',
            description: '회사 직장 동료와 대화하는 상황',
            isSelected: selectedIndex == 1,
            isDisabled: isNavigating && selectedIndex != 1,
            onTap: () => _handleItemTap(1),
          ),
          const SizedBox(height: 24),
          ConversationStyleItem(
            icon: SvgPicture.asset('assets/images/chat_icon.svg'),
            title: '부하 직원',
            description: '회사 부하 직원과 대화하는 상황',
            isSelected: selectedIndex == 2,
            isDisabled: isNavigating && selectedIndex != 2,
            onTap: () => _handleItemTap(2),
          ),
          const SizedBox(height: 24),
          ConversationStyleItem(
            icon: SvgPicture.asset('assets/images/talk_icon.svg'),
            title: '친구',
            description: '친구와 대화하는 상황',
            isSelected: selectedIndex == 3,
            isDisabled: isNavigating && selectedIndex != 3,
            onTap: () => _handleItemTap(3),
          ),
          const SizedBox(height: 24),
          ConversationStyleItem(
            icon: SvgPicture.asset('assets/images/heart_talk.svg'),
            title: '연인',
            description: '연인과 대화하는 상황',
            isSelected: selectedIndex == 4,
            isDisabled: isNavigating && selectedIndex != 4,
            onTap: () => _handleItemTap(4),
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
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const ConversationStyleItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.isSelected = false,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: isSelected ? HackerTonGradients.orangeToPink : null,
            color: isSelected ? null : HackerTonColors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ColorFiltered(
                  colorFilter: isSelected
                      ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                      : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.dst,
                        ),
                  child: icon,
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: HackerTonTypography.MainLarge.copyWith(
                        fontSize: 20,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        description,
                        style: HackerTonTypography.MainSmall.copyWith(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : HackerTonColors.grey200,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
