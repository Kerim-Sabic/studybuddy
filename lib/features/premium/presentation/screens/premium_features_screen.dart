import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';

/// Premium features and subscription management
class PremiumFeaturesScreen extends StatefulWidget {
  const PremiumFeaturesScreen({super.key});

  @override
  State<PremiumFeaturesScreen> createState() => _PremiumFeaturesScreenState();
}

class _PremiumFeaturesScreenState extends State<PremiumFeaturesScreen> {
  bool _isPremium = false; // Mock - would come from user profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Features'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isPremium) ...[
              _buildUpgradeBanner(),
              const SizedBox(height: 24),
              _buildPricingPlans(),
              const SizedBox(height: 24),
            ],

            _buildFeaturesComparison(),

            const SizedBox(height: 24),

            if (_isPremium) ...[
              _buildPremiumTools(),
              const SizedBox(height: 24),
            ],

            _buildFAQSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeBanner() {
    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.3),
              Colors.blue.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              '👑',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unlock Your Full Potential',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Get unlimited access to advanced features and supercharge your learning',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showUpgradeDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPricingCard(
                title: 'Monthly',
                price: '\$9.99',
                period: '/month',
                features: [
                  'All premium features',
                  'Cancel anytime',
                ],
                isPopular: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPricingCard(
                title: 'Yearly',
                price: '\$79.99',
                period: '/year',
                features: [
                  'All premium features',
                  'Save 33%',
                  'Priority support',
                ],
                isPopular: true,
                discount: 'BEST VALUE',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
    String? discount,
  }) {
    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: isPopular
            ? BoxDecoration(
                border: Border.all(color: Colors.amber, width: 2),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          children: [
            if (discount != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  discount,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _subscribeToPlan(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? Colors.amber : Colors.blue,
                minimumSize: const Size(double.infinity, 40),
              ),
              child: Text(
                'Select',
                style: TextStyle(
                  color: isPopular ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesComparison() {
    final features = [
      FeatureComparison('Flashcard Decks', '5 decks', 'Unlimited'),
      FeatureComparison('AI Study Coach', '10 queries/day', 'Unlimited'),
      FeatureComparison('Advanced Analytics', false, true),
      FeatureComparison('Export to PDF/CSV', false, true),
      FeatureComparison('Cloud Sync', '1 device', 'Unlimited devices'),
      FeatureComparison('Custom Badge Themes', false, true),
      FeatureComparison('Priority Support', false, true),
      FeatureComparison('Offline Mode', false, true),
      FeatureComparison('Study Groups', '1 group', 'Unlimited groups'),
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feature Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Feature',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Free',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Premium',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...features.map((feature) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(feature.name),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: _buildFeatureValue(feature.freeValue),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: _buildFeatureValue(feature.premiumValue),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureValue(dynamic value) {
    if (value is bool) {
      return Center(
        child: Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? Colors.green : Colors.red,
          size: 20,
        ),
      );
    } else {
      return Text(
        value.toString(),
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildPremiumTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Premium Tools',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildToolCard(
          icon: Icons.analytics,
          title: 'Advanced Analytics',
          description: 'Deep insights into your learning patterns',
          onTap: () {
            // Navigate to analytics dashboard
          },
        ),
        _buildToolCard(
          icon: Icons.file_download,
          title: 'Export Data',
          description: 'Export your study data to PDF or CSV',
          onTap: () => _showExportDialog(),
        ),
        _buildToolCard(
          icon: Icons.palette,
          title: 'Custom Themes',
          description: 'Unlock premium badge and UI themes',
          onTap: () => _showThemeSelector(),
        ),
        _buildToolCard(
          icon: Icons.cloud_sync,
          title: 'Cloud Sync Settings',
          description: 'Manage cloud sync across unlimited devices',
          onTap: () {
            // Navigate to cloud sync settings
          },
        ),
      ],
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      FAQ(
        'Can I cancel anytime?',
        'Yes! You can cancel your subscription at any time. You\'ll continue to have access until the end of your billing period.',
      ),
      FAQ(
        'What payment methods do you accept?',
        'We accept all major credit cards, PayPal, and Apple Pay.',
      ),
      FAQ(
        'Is there a student discount?',
        'Yes! Students with a valid .edu email address get 50% off any plan.',
      ),
      FAQ(
        'Can I try premium for free?',
        'Yes! We offer a 7-day free trial for new users.',
      ),
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...faqs.map((faq) {
              return ExpansionTile(
                title: Text(
                  faq.question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(faq.answer),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Upgrade to Premium'),
        content: const Text(
          'Ready to unlock all premium features and supercharge your learning?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _subscribeToPlan('Yearly');
            },
            child: const Text('Yes, Upgrade!'),
          ),
        ],
      ),
    );
  }

  void _subscribeToPlan(String plan) {
    // Mock subscription - would integrate with payment provider
    setState(() {
      _isPremium = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Subscribed to $plan plan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export to PDF'),
              subtitle: const Text('Comprehensive study report'),
              onTap: () {
                Navigator.pop(context);
                _exportData('PDF');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export to CSV'),
              subtitle: const Text('Raw data for analysis'),
              onTap: () {
                Navigator.pop(context);
                _exportData('CSV');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.blue),
              title: const Text('Export to JSON'),
              subtitle: const Text('Complete data backup'),
              onTap: () {
                Navigator.pop(context);
                _exportData('JSON');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportData(String format) {
    // Mock export - would generate actual file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📥 Exporting to $format...'),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Export complete! Saved to Downloads/$format'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showThemeSelector() {
    final themes = [
      BadgeTheme('Classic', '🎯', Colors.blue),
      BadgeTheme('Galaxy', '🌌', Colors.purple),
      BadgeTheme('Sunset', '🌅', Colors.orange),
      BadgeTheme('Forest', '🌲', Colors.green),
      BadgeTheme('Ocean', '🌊', Colors.cyan),
      BadgeTheme('Fire', '🔥', Colors.red),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Badge Themes'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${theme.emoji} ${theme.name} theme applied!'),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.color.withOpacity(0.2),
                    border: Border.all(color: theme.color, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        theme.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme.name,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class FeatureComparison {
  final String name;
  final dynamic freeValue;
  final dynamic premiumValue;

  FeatureComparison(this.name, this.freeValue, this.premiumValue);
}

class FAQ {
  final String question;
  final String answer;

  FAQ(this.question, this.answer);
}

class BadgeTheme {
  final String name;
  final String emoji;
  final Color color;

  BadgeTheme(this.name, this.emoji, this.color);
}
