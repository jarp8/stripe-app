import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';
import 'package:stripe_app/data/tarjetas.dart';
import 'package:stripe_app/helpers/helpers.dart';
import 'package:stripe_app/pages/tarjeta_page.dart';
import 'package:stripe_app/widgets/total_page_bottom.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final pagarBloc = BlocProvider.of<PagarBloc>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pagar'),
        actions: [
          IconButton(
            onPressed: () async {
              mostrarLoading(context);

              await Future.delayed(const Duration(milliseconds: 1000));

              if(context.mounted) {
                Navigator.pop(context);

                mostrarAlerta(context, 'Hola', 'Mundo');
              }  
            },
            icon: const Icon(Icons.add)
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            width: size.width,
            height: size.height,
            top: 200,
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: PageController(
                viewportFraction: 0.9
              ),
              itemCount: tarjetas.length,
              itemBuilder: (_, i) {
                final tarjeta = tarjetas[i];
            
                return GestureDetector(
                  onTap: () {
                    pagarBloc.add(OnSeleccionarTarjeta(tarjeta: tarjeta));

                    Navigator.push(context, navegarFadeIn(context, const TarjetaPage()));
                  },
                  child: Hero(
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
                );
              }
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