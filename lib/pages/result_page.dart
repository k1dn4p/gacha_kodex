import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ticket_provider.dart';
import '../widgets/app_bottom_nav.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getPrizeColor(String prizeLevel) {
    switch (prizeLevel) {
      case 'A':
        return Colors.amber;
      case 'B':
        return Colors.purple;
      case 'C':
        return Colors.cyan;
      case 'D':
        return Colors.green;
      case 'E':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  bool _hasFancyAnimation(String prizeLevel) {
    return ['A', 'B', 'C'].contains(prizeLevel);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.read<TicketProvider>().resetSelection();
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
          centerTitle: true,
          leading: const SizedBox.shrink(),
        ),
        body: Consumer<TicketProvider>(
          builder: (context, ticketProvider, child) {
            final selectedTicket = ticketProvider.selectedTicket;

            if (selectedTicket == null) {
              return const Center(
                child: Text('No ticket selected'),
              );
            }

            final prizeLevel = selectedTicket.prizeLevel;
            final prizeColor = _getPrizeColor(prizeLevel);
            final prizeTitle = selectedTicket.prizeTitle;
            final hasFancy = _hasFancyAnimation(prizeLevel);

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    prizeColor.withOpacity(0.1),
                    prizeColor.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final imageSize = constraints.biggest.shortestSide;
                          final image = SizedBox(
                            width: imageSize,
                            height: imageSize,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Image.asset(
                                selectedTicket.imagePathPrize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );

                          return Center(
                            child: hasFancy
                                ? ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: RotationTransition(
                                      turns: _rotateAnimation,
                                      child: image,
                                    ),
                                  )
                                : image,
                          );
                        },
                      ),
                    ),
                  ),
                  Text(
                    prizeTitle,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: prizeColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$prizeLevel 상입니다!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ticketProvider.resetSelection();
                      Navigator.pushReplacementNamed(context, '/gacha');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const AppBottomNav(
          currentIndex: 1,
        ),
      ),
    );
  }
}
