part of 'pagar_bloc.dart';

class PagarState {
  final double montoPagar;
  final String moneda;
  final bool tarjetaActiva;
  final TarjetaCredito? tarjeta;

  String get montoPagarString => '${(montoPagar * 100).floor()}';

  const PagarState({
    this.montoPagar = 250.55,
    this.moneda = 'USD',
    this.tarjetaActiva = false,
    this.tarjeta
  });

  PagarState copyWith({
    double? montoPagar,
    String? moneda,
    bool? tarjetaActiva,
    TarjetaCredito? tarjeta,
  }) => PagarState(
    montoPagar: montoPagar ?? this.montoPagar,
    moneda: moneda ?? this.moneda,
    tarjetaActiva: tarjetaActiva ?? this.tarjetaActiva,
    tarjeta: tarjeta ?? this.tarjeta,
  );
}
