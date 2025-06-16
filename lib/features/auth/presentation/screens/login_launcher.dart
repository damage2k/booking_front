import 'package:booking_front/features/employees/presentation/pages/employees_screen.dart';
import 'package:booking_front/features/map/presentation/screens/office_map_screen.dart';
import 'package:booking_front/shared/widgets/side_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_initializer.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../meeting/presentation/screens/meetings_screen.dart';
import '../providers/auth_providers.dart';
import '../widgets/login_modal.dart';
import '../widgets/session_expired_dialog.dart';

class LoginLauncher extends ConsumerStatefulWidget {
  const LoginLauncher({super.key});

  @override
  ConsumerState<LoginLauncher> createState() => _LoginLauncherState();
}

class _LoginLauncherState extends ConsumerState<LoginLauncher> {
  int selectedIndex = 0;

  bool initialized = false;
  bool showMobileMenu = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await initializeApp(ref);
      setState(() => initialized = true);

      if (ref.read(authTokenProvider) == null) {
        if (ref.read(sessionExpiredProvider)) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const SessionExpiredDialog(),
          );
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const LoginModal(),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile && ref.watch(authTokenProvider) != null)
                SideNav(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      onBurgerTap: () => setState(() => showMobileMenu = true),
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: const [
                          OfficeMapScreen(),
                          MeetingsScreen(),
                          // Добавим заглушки, если нужны другие экраны
                          EmployeesScreen(),
                          Center(child: Text('Отчёты')),
                          Center(child: Text('Настройки')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // затемнение при открытом бургер-меню
            if (showMobileMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => showMobileMenu = false),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),

          // само меню
          if (showMobileMenu  && ref.watch(authTokenProvider) != null)
            Positioned(
              top: 0,
              left: 0,
              child: Material(
                elevation: 8,
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  color: Colors.white,
                  child: SideNav(
                    selectedIndex: 0,
                    onItemSelected: (index) {
                      setState(() {
                        showMobileMenu = false;
                        selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
