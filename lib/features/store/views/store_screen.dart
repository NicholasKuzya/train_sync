import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
      ),
      body: Text('Soon...')
      // Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         'Subscriptions',
      //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      //       ),
      //       SizedBox(height: 16),
      //       SubscriptionCard(
      //         title: 'Monthly Subscription',
      //         price: '\$9.99/month',
      //         description: 'Get access to all features for one month.',
      //         onTap: () {
      //           // Handle subscription purchase
      //         },
      //       ),
      //       SizedBox(height: 16),
      //       SubscriptionCard(
      //         title: 'Yearly Subscription',
      //         price: '\$99.99/year',
      //         description: 'Get access to all features for one year.',
      //         onTap: () {
      //           // Handle subscription purchase
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final VoidCallback onTap;

  const SubscriptionCard({
    required this.title,
    required this.price,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                price,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}