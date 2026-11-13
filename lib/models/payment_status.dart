enum PaymentStatus {
  pending,
  paid,
  paidEarly,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.paidEarly:
        return 'Paid Early';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'paid':
        return PaymentStatus.paid;
      case 'paidEarly':
        return PaymentStatus.paidEarly;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}
