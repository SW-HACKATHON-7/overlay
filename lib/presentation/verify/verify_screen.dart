import 'package:flutter/material.dart';
import 'package:hackerton/core/design_system/color.dart';
import 'package:hackerton/core/design_system/typography.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  bool locationPermission = false;
  bool cameraPermission = false;
  bool notificationPermission = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HackerTonColors.white,
      appBar: AppBar(
        backgroundColor: HackerTonColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: HackerTonColors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    const SizedBox(height: 60),
                    PermissionItem(
                      label: '내 위치에 대한 허용',
                      isChecked: locationPermission,
                      onChanged: (value) {
                        setState(() {
                          locationPermission = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    PermissionItem(
                      label: '카근성 기능 허용',
                      isChecked: cameraPermission,
                      onChanged: (value) {
                        setState(() {
                          cameraPermission = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    PermissionItem(
                      label: '오바데이 기능 허용',
                      isChecked: notificationPermission,
                      onChanged: (value) {
                        setState(() {
                          notificationPermission = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
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
                  onPressed: () {
                    // 다음으로 버튼 동작
                  },
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
