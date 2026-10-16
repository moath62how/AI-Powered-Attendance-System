enum OnboardingIllustrationType { checkIn, proximity, stats }

class OnboardingPageData {
  final String title;
  final String description;
  final OnboardingIllustrationType type;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.type,
  });
}
