import 'package:flutter/material.dart';
import 'package:rahal/component/my_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHome', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            PageView(
              controller: controller,
              onPageChanged: (index) {
                setState(() => isLastPage = index == 2);
              },
              children: [
                buildPage(
                  image: 'assets/images/onboarding1.jpg',
                  text: 'In 1922 Tutankhamun`s tomb was discovered, after few days one of the Archaeologists working on this discovery, have disappeared',
                  onNext: () => controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                ),
                buildPage(
                  image: 'assets/images/onboarding2.jpg',
                  text: 'All that was found that he was working on decipher some of the scrolls found, In a scroll that he decoded, he found a spell which send him to the world of everywhere and nowhere',
                  onNext: () => controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                  onBack: () => controller.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                ),
                buildPage(
                  image: 'assets/images/onboarding3.jpg',
                  text: 'This world called "The Path" where all time lines meet. He found a way to connect with the present, and a counter spell, but he does not know the side effects of using it, as he has been in nowhere for more than 100 years. This Archaeologist is Rah-hal.',
                  buttonText: 'START THE JOURNEY',
                  onNext: () async {
                    await completeOnboarding();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  onBack: () => controller.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      type: WormType.thin,
                      activeDotColor: Color.fromRGBO(255, 170, 4, 10),
                    ),
                  ),
                  SizedBox(height: 20),
                  isLastPage
                      ? MyButton(
                    onTap: () async {
                      await completeOnboarding();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    text: 'START THE JOURNEY',
                  )
                      : MyButton(
                    onTap: () => controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    text: 'NEXT',
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String text,
    String buttonText = 'NEXT',
    required VoidCallback onNext,
    VoidCallback? onBack,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(40, 40, 40, 100),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
            if (onBack != null)
              Positioned(
                top: 40,
                left: 0,
                child: GestureDetector(
                  onTap: onBack,
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_left,
                        color: Color.fromRGBO(255, 170, 4, 10),
                      ),
                      Text(
                        'BACK',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 170, 4, 10),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!isLastPage)
              Positioned(
                top: 40,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    completeOnboarding();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Row(
                    children: [
                      Text(
                        'SKIP',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 170, 4, 10),
                          fontSize: 18,
                        ),
                      ),
                      Icon(
                        Icons.arrow_right,
                        color: Color.fromRGBO(255, 170, 4, 10),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
