import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pet_pulse/features/subscription/services/subscription_service.dart';

class PaywallScreen extends StatefulWidget {
  final SubscriptionService? subscriptionService;
  
  const PaywallScreen({super.key, this.subscriptionService});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late final SubscriptionService _subscriptionService;
  List<Package> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subscriptionService = widget.subscriptionService ?? SubscriptionService();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() => _isLoading = true);
    try {
      // Ensure SDK is initialized in main.dart before calling this in a real app
      // await _subscriptionService.init(); 
      final packages = await _subscriptionService.getOfferings();
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchase(Package package) async {
    setState(() => _isLoading = true);
    final success = await _subscriptionService.purchasePackage(package);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Welcome to PetPulse Pro!")),
      );
      Navigator.of(context).pop(); // Close paywall
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFF8F94FB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.pets, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                "Unlock PetPulse Pro",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  "Unlimited AI Scans, Priority Vet Booking, and Exclusive Deals.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const Spacer(),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final package = _packages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            package.storeProduct.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(package.storeProduct.description),
                          trailing: Text(
                            package.storeProduct.priceString,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                          onTap: () => _purchase(package),
                        ),
                      );
                    },
                  ),
                ),
              TextButton(
                onPressed: () async {
                  await _subscriptionService.restorePurchases();
                },
                child: const Text(
                  "Restore Purchases",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
