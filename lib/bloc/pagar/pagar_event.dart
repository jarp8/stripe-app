part of 'pagar_bloc.dart';

sealed class PagarEvent {}

class OnSeleccionarTarjeta extends PagarEvent {
  final TarjetaCredito tarjeta;

  OnSeleccionarTarjeta({required this.tarjeta});
}

class OnDesactivarTarjeta extends PagarEvent {}
