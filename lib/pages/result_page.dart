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

  String _getPrizeEmoji(String prizeLevel) {
    switch (prizeLevel) {
      case 'A':
        return '✨';
      case 'B':
        return '⭐';
      case 'C':
        return '💫';
      case 'D':
        return '🔹';
      case 'E':
        return '⚪';
      default:
        return '🎁';
    }
  }

  String _getPrizeTitle(String prizeLevel) {
    switch (prizeLevel) {
      case 'A':
        return 'LEGENDARY';
      case 'B':
        return 'EPIC';
      case 'C':
        return 'RARE';
      case 'D':
        return 'UNCOMMON';
      case 'E':
        return 'COMMON';
      case 'F':
        return 'Below Common';
      default:
        return 'PRIZE';
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
              final prizeEmoji = _getPrizeEmoji(prizeLevel);
              final prizeTitle = _getPrizeTitle(prizeLevel);
              final hasFancy = _hasFancyAnimation(prizeLevel);

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [prizeColor.withOpacity(0.1), prizeColor.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          'Congratulations!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        if (hasFancy)
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: RotationTransition(
                              turns: _rotateAnimation,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: prizeColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: prizeColor.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                      selectedTicket.imagePathPrize,
                                      height: 88,
                                      fit: BoxFit.contain,
                                    )
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: prizeColor,
                            ),
                            child: Center(
                              child: Image.asset(
                                  selectedTicket.imagePathPrize,
                                  height: 88,
                                  fit: BoxFit.contain,
                              )
                            ),
                          ),
                        const SizedBox(height: 40),
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
                          'Prize Level: ${prizeLevel}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (hasFancy)
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: prizeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: prizeColor,
                                width: 2,
                              ),
                            ),
                            child: const Text(
                              '🎉 축하합니다! 상위상을 뽑았습니다! 🎉',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                ticketProvider.resetSelection();
                                Navigator.pushReplacementNamed(context, '/gacha');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Try Again'),
                            ),
                            const SizedBox(width: 15),
                            ElevatedButton(
                              onPressed: () {
                                ticketProvider.resetSelection();
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Main Menu'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0, // 현재 페이지에 맞게 바꾸기
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '메인',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: '현황',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: '설정',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/');
              } else if (index == 1) {
                Navigator.pushReplacementNamed(context, '/status');
              } else if (index == 2) {
                Navigator.pushReplacementNamed(context, '/settings');
              }
            },
          ),
        ),
      );
    }
  }
