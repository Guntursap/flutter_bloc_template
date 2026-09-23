// lib/page/home.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/core/utility/formatters.dart';
import 'package:flutter_bloc_template/core/utility/notification_widget.dart';
import 'package:flutter_bloc_template/data/auth/bloc/verify/verify_bloc.dart';
import 'package:flutter_bloc_template/data/items/bloc/items_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ItemsBloc()..add(ItemsRequested())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Items'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<VerifyBloc>().add(LogoutRequested()),
            ),
          ],
        ),
        body: BlocConsumer<VerifyBloc, VerifyState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              Navigator.pushReplacementNamed(context, '/login');
            } else if (state is LogoutFailure) {
              showAppMessage(context, state.errorMessage, isError: true);
            }
          },
          listenWhen: (p, c) => c is LogoutSuccess || c is LogoutFailure,
          builder: (context, _) => BlocBuilder<ItemsBloc, ItemsState>(
            builder: (context, state) => switch (state) {
              ItemsLoading() =>
                const Center(child: CircularProgressIndicator()),
              ItemsFailure(:final errorMessage) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMessage),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context
                            .read<ItemsBloc>()
                            .add(ItemsRequested()),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ItemsSuccess(:final products) when products.isEmpty =>
                const Center(child: Text('Belum ada data')),
              ItemsSuccess(:final products, :final total) =>
                RefreshIndicator(
                  onRefresh: () async => context
                      .read<ItemsBloc>()
                      .add(ItemsRequested()),
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = products[i];
                      return ListTile(
                        title: Text(p.title),
                        subtitle: Text(formatPrice(p.price)),
                        trailing: Text('#$total'),
                        onTap: () => Navigator.pushNamed(
                          context, '/item_detail',
                          arguments: {'id': p.id},
                        ),
                      );
                    },
                  ),
                ),
              _ => const SizedBox(),
            },
          ),
        ),
      ),
    );
  }
}
