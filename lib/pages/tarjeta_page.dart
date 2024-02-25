import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';
import 'package:stripe_app/widgets/total_pay_button.dart';

class TarjetaPage extends StatelessWidget {
  const TarjetaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pagarBloc = BlocProvider.of<PagarBloc>(context);

    final tarjeta = pagarBloc.state.tarjeta!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pagar'),
        leading: BackButton(
          onPressed: () {
            pagarBloc.add(OnDesactivarTarjeta());

            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(),

          Hero(
            tag: tarjeta.cardNumber,
            child: CreditCardWidget(
              cardNumber: tarjeta.cardNumberHidden,
              expiryDate: tarjeta.expiracyDate,
              cardHolderName: tarjeta.cardHolderName,
              cvvCode: tarjeta.cvv,
              showBackView: false,
              isSwipeGestureEnabled: false,
              onCreditCardWidgetChange: (value) {}
            ),
          ),
          
          const Positioned(
            bottom: 0,
            child: TotalPayButton(),
          )
        ],
      )
   );
  }
}