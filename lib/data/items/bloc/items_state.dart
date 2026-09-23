part of 'items_bloc.dart';

@immutable
abstract class ItemsState {}

class ItemsInitial extends ItemsState {}
class ItemsLoading extends ItemsState {}

class ItemsSuccess extends ItemsState {
  final List<Product> products;
  final int total;
  ItemsSuccess({required this.products, required this.total});
}

class ItemsFailure extends ItemsState {
  final String errorMessage;
  ItemsFailure(this.errorMessage);
}

class ItemDetailLoading extends ItemsState {}
class ItemDetailFailure extends ItemsState {
  final String errorMessage;
  ItemDetailFailure(this.errorMessage);
}

class ItemDetailSuccess extends ItemsState {
  final Product product;
  ItemDetailSuccess({required this.product});
}
