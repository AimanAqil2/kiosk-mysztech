import '../../domain/models/order.dart';

abstract interface class CheckoutRepository {
  Future<SubmittedOrder> submit(OrderSubmission submission);
}
