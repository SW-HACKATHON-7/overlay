import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackAppbar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        iconSize: 24,
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => context.pop(),
        color: Colors.grey,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
