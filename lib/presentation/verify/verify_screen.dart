import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/typography.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hackerton/services/screenshot_service.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> with WidgetsBindingObserver {
  bool locationPermission = false;
  bool cameraPermission = false;
  bool notificationPermission = false;

  bool get allPermissionsGranted =>
      locationPermission && cameraPermission && notificationPermission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  Future<void> _checkAllPermissions() async {
    await _checkOverlayPermission();
    await _checkScreenCapturePermission();
    await _checkAccessibilityPermission();
  }

  Future<void> _checkOverlayPermission() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    setState(() {
      notificationPermission = granted;
    });
  }

  Future<void> _checkScreenCapturePermission() async {
    final granted = await ScreenshotService.hasPermission();
    setState(() {
      locationPermission = granted;
    });
  }

  Future<void> _checkAccessibilityPermission() async {
    final granted = await ScreenshotService.checkAccessibilityPermission();
    setState(() {
      cameraPermission = granted;
    });
  }

  Future<void> _requestScreenCapturePermission() async {
    final granted = await ScreenshotService.requestPermission();
    setState(() {
      locationPermission = granted;
    });
  }

  Future<void> _requestAccessibilityPermission() async {
    await ScreenshotService.requestAccessibilityPermission();
    // 설정 화면에서 돌아오면 다시 체크
  }

  Future<void> _requestOverlayPermission() async {
    final granted = await FlutterOverlayWindow.requestPermission();
    if (granted == true) {
      setState(() {
        notificationPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    '권한을 허용해 주세요',
                    style: HackerTonTypography.MainLarge.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '대화 복기를 위해 권한 허용이 필요해요',
                    style: HackerTonTypography.MainSmall.copyWith(
                      fontSize: 14,
                      color: HackerTonColors.grey,
                    ),
                  ),
                  Spacer(),
                  PermissionItem(
                    label: '내 화면 대한 허용',
                    isChecked: locationPermission,
                    onChanged: (value) async {
                      if (value == true) {
                        await _requestScreenCapturePermission();
                      } else {
                        setState(() {
                          locationPermission = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  PermissionItem(
                    label: '접근성 기능 허용',
                    isChecked: cameraPermission,
                    onChanged: (value) async {
                      if (value == true) {
                        await _requestAccessibilityPermission();
                      } else {
                        setState(() {
                          cameraPermission = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  PermissionItem(
                    label: '오버레이 기능 허용',
                    isChecked: notificationPermission,
                    onChanged: (value) async {
                      if (value == true) {
                        await _requestOverlayPermission();
                      } else {
                        setState(() {
                          notificationPermission = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: HackerTonGradients.orangeToPink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: allPermissionsGranted
                      ? () {
                          context.push('/choose_partner');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text('다음으로', style: HackerTonTypography.MainMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionItem extends StatelessWidget {
  final String label;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;

  const PermissionItem({
    super.key,
    required this.label,
    required this.isChecked,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(
          label,
          style: HackerTonTypography.MainSmall.copyWith(
            fontSize: 14,
            color: HackerTonColors.black,
          ),
        ),
        value: isChecked,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: HackerTonColors.pink,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
