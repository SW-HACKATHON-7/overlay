import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/icon.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/presentation/analysis_result/analysis_result_notifier.dart';
import 'package:hackerton/presentation/choosePartner/choose_partner_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int index = 0;
  bool _hasCheckedAnalysisResult = false;

  final pages = [
    HomeScreen(),
    ChoosePartnerScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 분석 결과 체크 및 자동 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigateToAnalysisResult();
    });
  }

  void _checkAndNavigateToAnalysisResult() {
    if (_hasCheckedAnalysisResult) return;

    print('MainScreen: 분석 결과 체크 중...');
    final analysisState = ref.read(analysisResultNotifierProvider);

    if (analysisState.messages.isNotEmpty) {
      print('MainScreen: 분석 결과 발견! ${analysisState.messages.length}개 메시지');
      print('MainScreen: 분석 결과 화면으로 이동 시작');

      _hasCheckedAnalysisResult = true;

      // 여러 방법으로 시도
      Future.delayed(const Duration(milliseconds: 200), () {
        print('MainScreen: context.push 시도');
        try {
          context.push('/analysis_result');
          print('✓ context.push 완료');
        } catch (e) {
          print('❌ context.push 실패: $e');
        }
      });
    } else {
      print('MainScreen: 분석 결과 없음');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        currentIndex: index,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: HackerTonIcon.robotIcon(), label: ''),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var index = 0;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 59),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '반가워요 사용자 님',
                    style: HackerTonTypography.MainLarge.copyWith(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '7일 전 분석보다 점수가 올랐어요',
                    style: HackerTonTypography.MainSmall.copyWith(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 사용자 정보 카드
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 11),
                    decoration: BoxDecoration(
                      color: HackerTonColors.grey50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/user_profile.svg',
                          width: 48,
                          height: 48,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '서정현 / 18',
                              style: HackerTonTypography.MainMedium.copyWith(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '부산소프트웨어마이스터고등학교',
                              style: HackerTonTypography.MainSmall.copyWith(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 19, vertical: 17),
                    decoration: BoxDecoration(
                      color: HackerTonColors.grey50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/circle.svg',
                            ),
                            const SizedBox(width: 18),
                            Column(children: [
                              Text(
                                '사용자 님의 채팅 점수는',
                                style: HackerTonTypography.MainSmall.copyWith(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '72점 입니다',
                                style: HackerTonTypography.MainMedium.copyWith(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ])
                          ],
                        ),
                        const SizedBox(height: 15),

                        // 장점 섹션
                        _buildBulletPoint(
                          '추천해요',
                          '+ 항상 존대말을 사용하시고 있어요',
                          '+ 시간 등 약속 시간을 명확하게 표현하고 있어요',
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        _buildBulletPoint(
                          '개선하면 좋을 것 같아요',
                          '- “아 그게...”로 시작하는 변명성 어투가 잦아요',
                          '- "조금 더", "최대한 빨리" 등 추상적인 시간묘사가  많아요',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 11),
                    decoration: BoxDecoration(
                      color: HackerTonColors.grey50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 사용자님이 자주 사용한 말투
                        Text('사용자님이 자주 사용한 말투',
                            style: HackerTonTypography.MainLarge.copyWith(
                              fontSize: 16,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildQuoteBox('"아~ 그게"'),
                        const SizedBox(height: 9),
                        _buildQuoteBox('"죄송합니다"'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/choose_partner');
          },
          backgroundColor: Colors.transparent, // 필수. 기본 배경 제거
          elevation: 6,
          child: Ink(
            decoration: BoxDecoration(
              gradient: HackerTonGradients.orangeToPink,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 56, // FAB 기본 크기
              height: 56, // FAB 기본 크기
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ));
  }

  Widget _buildBulletPoint(
      String title, String recommended1, String recommended2) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            title,
            style: HackerTonTypography.MainLarge.copyWith(
              fontSize: 15,
              color: HackerTonColors.pink,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            recommended1,
            style: HackerTonTypography.MainSmall.copyWith(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            recommended2,
            style: HackerTonTypography.MainSmall.copyWith(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ]));
  }

  Widget _buildQuoteBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: AlignmentGeometry.center,
        child: Text(text,
            style: HackerTonTypography.MainSmall.copyWith(
              fontSize: 18,
              color: Colors.black,
            )),
      ),
    );
  }
}
