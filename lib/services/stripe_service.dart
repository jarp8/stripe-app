

import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_app/models/payment_intent_response.dart';
import 'package:stripe_app/models/stripe_custom_response.dart';

class StripeService {

  // Singleton
  StripeService._privateConstructor();
  static final StripeService _instance = StripeService._privateConstructor();
  factory StripeService () => _instance;

  final dio = Dio();

  final String _paymentApiUrl = 'https://api.stripe.com/v1/payment_intents';
  static const String _secretKey = 'sk_test_51On670EjFAEo2TDMz1O65vLGYr23X2FDIWxQVcW7ncJt95jnHOlsywmamaqqbbhjXTlIbK3UbsHX6jQT428CuXyN000grQNVgV';
  final String _apiKey = 'pk_test_51On670EjFAEo2TDMMEWvUXyoLwz6ElsIraZKUY1HGq6t0kg6KWQekNxU4fE69GRoILfN8n2FO6Cw4YHqNHNAiPJJ00UkIZeI8X';

  final headerOptions = Options(
    contentType: Headers.formUrlEncodedContentType,
    headers: {
      'Authorization': 'Bearer $_secretKey'
    }
  );

  void init() async {
    Stripe.publishableKey = _apiKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    await Stripe.instance.applySettings();
  }

  Future<StripeCustomResponse> pagarConTarjetaExistente({
    required String amount,
    required String currency,
    required CardDetails card,
  }) async {
    try {
      await Stripe.instance.dangerouslyUpdateCardDetails(card);

      const billingDetails = BillingDetails();

      Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData()
        )
      );

      final resp = await _crearPaymentIntent(amount: amount, currency: currency);

      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: resp.clientSecret!,
        data: const PaymentMethodParams.card(
           paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails
        ))
      );
      
      return StripeCustomResponse(ok: true);
    } catch (e) {
      return StripeCustomResponse(ok: false, message: e.toString()); 
    }
  }

  Future<StripeCustomResponse> pagarConNuevaTarjeta({
    required String amount,
    required String currency,
  }) async {
       try {
        final resp = await _crearPaymentIntent(
          amount: amount,
          currency: currency
        );

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            merchantDisplayName: 'test',
            paymentIntentClientSecret: resp.clientSecret,
          )
        );

        await Stripe.instance.presentPaymentSheet();
      
      return StripeCustomResponse(ok: true);
    } catch (e) {
      return StripeCustomResponse(ok: false, message: e.toString());
    } 
  }

  Future<StripeCustomResponse> pagarApplePayGooglePay({
      required String amount,
      required String currency,
  }) async {
    try {
      final resp = await _crearPaymentIntent(
        amount: amount,
        currency: currency
      );

      final googlePaySupported = await Stripe.instance
        .isPlatformPaySupported(googlePay: const IsGooglePaySupportedParams());
      if (googlePaySupported) {
        // 2.present google pay sheet
        await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: resp.clientSecret!,
          confirmParams: PlatformPayConfirmParams.googlePay(
            googlePay: GooglePayParams(
              testEnv: true,
              merchantName: 'Example Merchant Name',
              merchantCountryCode: 'US',
              currencyCode: currency,
            ),
          )
        // PresentGooglePayParams(clientSecret: clientSecret),
        );    
      } else {
        await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: resp.clientSecret!,
          confirmParams: PlatformPayConfirmParams.applePay(
            applePay: ApplePayParams(
              merchantCountryCode: 'US',
              currencyCode: currency,
              cartItems: [
                ApplePayCartSummaryItem.immediate(
                  label: 'Example Merchant Name',
                  amount: amount
                )
              ]
            )
          )
        );
      }



      return StripeCustomResponse(ok: true);
    } catch (e) {
      print('Error en intento ${e.toString()}');

      return StripeCustomResponse(
        ok: false,
        message: e.toString()
      );
    }
  }

  Future<PaymentIntentResponse> _crearPaymentIntent({
      required String amount,
      required String currency,
  }) async {
    try {
      final dio = Dio();
      final data = {
        'amount': amount,
        'currency': currency      
      };

      final resp = await dio.post(
        _paymentApiUrl,
        data: data,
        options: headerOptions
      );

      return PaymentIntentResponse.fromMap(resp.data);
    } catch (e) {
      print('Error en intento ${e.toString()}');

      return PaymentIntentResponse(status: '400');
    }
  }
}