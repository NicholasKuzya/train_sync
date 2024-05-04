import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io' show Platform;
import 'dart:async';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<dynamic> subscriptions = [];
  int? _selectedSubscriptionIndex;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> _fetchSubscriptionsPlan() async {
    ProductDetailsResponse productDetailsResponse = await InAppPurchase.instance.queryProductDetails(
      Platform.isIOS ? {'21481827'} : {'21481827'},
    );

    List<ProductDetails> products = productDetailsResponse.productDetails;
    List<Map<String, dynamic>> fakeProductDetails = [
      {
        'title': 'Подписка на месяц',
        'price': '\$9.99',
        'description': 'Подписка на доступ к премиум-контенту в течение месяца.',
      },
      {
        'title': 'Подписка на год',
        'price': '\$99.99',
        'description': 'Подписка на доступ к премиум-контенту в течение года. Скидка 20%!',
      },
      // Добавьте здесь больше продуктов, если нужно
    ];
    setState(() {
      subscriptions = products.map((product) => {
        'name': product.title,
        'price': product.price,
        'description': product.description,
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionsPlan();
    _listenToPurchaseUpdated();
  }

  void _listenToPurchaseUpdated() {
    _subscription = InAppPurchase.instance.purchaseStream.listen((purchaseDetailsList) {
      for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          _handlePurchasedSubscription(purchaseDetails);
        }
      }
    });
  }

  void _handlePurchasedSubscription(PurchaseDetails purchaseDetails) {
    // Здесь вы можете выполнить запрос к вашему серверу,
    // чтобы сохранить информацию о покупке в вашей базе данных
    // Например:
    // sendPurchaseToServer(purchaseDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
      ),
      body: ListView.builder(
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final subscription = subscriptions[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubscriptionIndex = index;
              });
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription['name'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text('\$${subscription['price']}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: _selectedSubscriptionIndex != null
          ? FloatingActionButton.extended(
        onPressed: () {
          // Вызов метода для покупки подписки
          _buySubscription(subscriptions[_selectedSubscriptionIndex!]);
        },
        label: Text('Subscribe'),
        icon: Icon(Icons.subscriptions),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _buySubscription(dynamic subscription) {
    // Предполагается, что у вашей подписки есть идентификатор, который нужно передать для покупки
    // В этом примере предполагается, что идентификатор подписки доступен в ключе 'productId'
    String productId = subscription['productId'];
    InAppPurchase.instance.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: subscription));
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
