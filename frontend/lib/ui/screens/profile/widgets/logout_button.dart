import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onLogout,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/profile_icons/logout_icon.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                const Color(0xFFC12530),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: const Color(0xFFC12530),
              ),
            ),
          ],
        ),
      ),
    );
  }
}