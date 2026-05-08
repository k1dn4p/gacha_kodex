import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/ticket_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('히경이 쿠지샵'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                '히경이 전용 쿠지샵에 \n 오신걸 환영합니다!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '쿠지란 무엇인가?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    const Text(
                      '쿠지는 티켓 하나당 12,000원에서 15,000원을 소비해서 10개에 만원인 꽝들을 뽑는 게임입니다.' ,
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '그리고 그 차액은 바로 도파민으로 환산되죠!' ,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    for (final entry in ticketProvider.currentPrizeNames.entries)
                      Text(
                        '${entry.key} : ${entry.value}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 15),
                    const Text(
                      '각 티켓마다 이미 정해진 결과가 있으며, 초기화 전에는 그 위치나 결과는 바뀌지 않습니다.',
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/gacha');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  '가챠 뽑기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/status');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 42,
                    vertical: 15,
                  ),
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                ),
                child: const Text(
                  '현황판 보기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
