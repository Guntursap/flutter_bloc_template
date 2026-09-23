import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/data/items/model/product.dart';
import 'package:flutter_bloc_template/data/items/repository/items_repository.dart';

part 'items_event.dart';
part 'items_state.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final ItemsRepo repo;
  ItemsBloc({ItemsRepo? repo})
      : repo = repo ?? ItemsRepo(),
        super(ItemsInitial()) {
    on<ItemsRequested>(_onList);
    on<ItemDetailRequested>(_onDetail);
  }

  Future<void> _onList(ItemsRequested e, Emitter<ItemsState> emit) async {
    emit(ItemsLoading());
    try {
      final res = await repo.getItems();
      if (res.status == 'failed') {
        emit(ItemsFailure(res.errorMessage ?? 'Gagal memuat data'));
      } else {
        emit(ItemsSuccess(products: res.products, total: res.total));
      }
    } catch (_) {
      emit(ItemsFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  Future<void> _onDetail(
      ItemDetailRequested e, Emitter<ItemsState> emit) async {
    emit(ItemDetailLoading());
    try {
      final res = await repo.getItemDetail(e.id);
      if (res.status == 'failed' || res.product == null) {
        emit(ItemDetailFailure(res.errorMessage ?? 'Data tidak ditemukan'));
      } else {
        emit(ItemDetailSuccess(product: res.product!));
      }
    } catch (_) {
      emit(ItemDetailFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }
}
