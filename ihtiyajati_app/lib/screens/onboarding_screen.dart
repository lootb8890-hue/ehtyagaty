// ============================================================================
// شاشة الترحيب والتعريف (Onboarding Screen)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../config/app_theme.dart';
import '../config/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'كل احتياجاتك في مكان واحد',
      'desc': 'نوفر لك في تطبيق احتياجاتي تجربة تسوق متكاملة تشمل البقالة، المطاعم، الصيدليات، ومواد البناء بأسهل الطرق.',
      'icon': '📦',
    },
    {
      'title': 'خدمة التوصيل الثقيل والسريع',
      'desc': 'سواء كنت تطلب وجبة غداء أو أطناناً من حديد التسليح والسمنت، أسطولنا جاهز للتوصيل مباشرة لموقعك في كربلاء.',
      'icon': '🚚',
    },
    {
      'title': 'منظومة إدارية متكاملة للجميع',
      'desc': 'ربط مباشر بين الزبون، الكابتن، وأصحاب المحلات لضمان وصول طلبك وتجهيزه بأسرع وقت وأقل كلفة.',
      'icon': '⚙️',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.go('/account-type'),
                    child: const Text(
                      'تخطي',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                    ),
                  ),
                ),
                
                const Spacer(),

                // Slides PageView
                SizedBox(
                  height: 380,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Emoji / Graphic representation
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                slide['icon']!,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 32),
                          Text(
                            slide['title']!,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              slide['desc']!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Spacer(),

                // Smooth Page Indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _slides.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: AppTheme.primaryGold,
                    dotColor: AppTheme.borderDark,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                  ),
                ),
                
                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: AppConstants.animMedium,
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/account-type');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1 ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
