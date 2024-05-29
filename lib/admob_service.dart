// ad_banner.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdMobService {
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5809591891527785/9514483540';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5809591891527785/2294469071'; // замените на ваш iOS идентификатор
    }
    return null;
  }
}

class AdBanner extends StatefulWidget {
  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId!, // Замените на ваш идентификатор блока рекламы
      request: AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Failed to load a banner ad: ${error.message}');
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isBannerAdReady
        ? Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    )
        : SizedBox.shrink();
  }
}
