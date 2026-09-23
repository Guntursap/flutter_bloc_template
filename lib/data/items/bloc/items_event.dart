part of 'items_bloc.dart';

@immutable
abstract class ItemsEvent {}

class ItemsRequested extends ItemsEvent {}

class ItemDetailRequested extends ItemsEvent {
  final int id;
  ItemDetailRequested(this.id);
}
