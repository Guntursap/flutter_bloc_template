// lib/page/item_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/core/utility/formatters.dart';
import 'package:flutter_bloc_template/data/items/bloc/items_bloc.dart';

class ItemDetailPage extends StatelessWidget {
  final int itemId;
  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ItemsBloc()..add(ItemDetailRequested(itemId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: BlocBuilder<ItemsBloc, ItemsState>(
          builder: (context, state) => switch (state) {
            ItemDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            ItemDetailFailure(:final errorMessage) =>
              Center(child: Text(errorMessage)),
            ItemDetailSuccess(:final product) => ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(product.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(formatPrice(product.price),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 12),
                  Text(product.description),
                ],
              ),
            _ => const SizedBox(),
          },
        ),
      ),
    );
  }
}
