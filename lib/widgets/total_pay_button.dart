import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';
import 'package:stripe_app/helpers/alertas.dart';
import 'package:stripe_app/services/stripe_service.dart';

class TotalPayButton extends StatelessWidget {

  const TotalPayButton({super.key});

  @override
  Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Text('250.55 USD', style: TextStyle(fontSize: 20))
            ],
          ),

          BlocBuilder<PagarBloc, PagarState>(
            builder: (context, state) {
              return _BtnPay(isNormalTarjeta: state.tarjetaActiva,);
            },
          )
        ],
      ),
    );
  }
}

class _BtnPay extends StatelessWidget {
  const _BtnPay({required this.isNormalTarjeta});

  final bool isNormalTarjeta;

  @override
  Widget build(BuildContext context) {
    return isNormalTarjeta
      ? buildBotonTarjeta(context)
      : buildAppleAndGooglePay(context);
  }

  Widget buildAppleAndGooglePay(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        final stripeService = StripeService();
        final pagarBlocState = BlocProvider.of<PagarBloc>(context).state;

        final resp = await stripeService.pagarApplePayGooglePay(
          amount: pagarBlocState.montoPagarString,
          currency: pagarBlocState.moneda
        );
      },
      height: 45,
      minWidth: 150,
      shape: const StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      child: Row(
        children: [
          Icon(
            Platform.isAndroid
              ? FontAwesomeIcons.google
              : FontAwesomeIcons.apple,
            color: Colors.white
          ),
          const Text('Pay', style: TextStyle(color: Colors.white, fontSize: 22))
        ],
      ),
    );
  }

  Widget buildBotonTarjeta(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        mostrarLoading(context);

        final stripeService = StripeService();
        final pagarBlocState = BlocProvider.of<PagarBloc>(context).state;
        final tarjeta = pagarBlocState.tarjeta!;
        final mesAnio = tarjeta.expiracyDate.split('/');

        final resp = await stripeService.pagarConTarjetaExistente(
          amount: pagarBlocState.montoPagarString,
          currency: pagarBlocState.moneda,
          card: CardDetails(
            number: tarjeta.cardNumber,
            expirationMonth: int.parse(mesAnio[0]),
            expirationYear: int.parse(mesAnio[1]),
            cvc: tarjeta.cvv
          )
        );

        Navigator.pop(context);

        if(resp.ok) {
          mostrarAlerta(context, 'Tarjeta Ok', 'Todo Correcto');
        } else {
          print(resp.message);
          mostrarAlerta(context, 'Algo salió mal', resp.message!);
        }
      },
      height: 45,
      minWidth: 150,
      shape: const StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      child: const Row(
        children: [
          Icon(FontAwesomeIcons.solidCreditCard, color: Colors.white),
          Text('  Pay', style: TextStyle(color: Colors.white, fontSize: 22))
        ],
      ),
    );
  }
}