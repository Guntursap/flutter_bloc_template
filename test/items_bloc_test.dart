import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_bloc_template/data/items/bloc/items_bloc.dart';
import 'package:flutter_bloc_template/data/items/repository/items_repository.dart';

void main() {
  MockClient client() => MockClient((req) async {
        if (req.url.path == '/products') {
          return http.Response(
              json.encode({
                'products': [
                  {'id': 1, 'title': 'A', 'price': 10}
                ],
                'total': 1
              }),
              200);
        }
        return http.Response(
            json.encode({'id': 1, 'title': 'A', 'price': 10}), 200);
      });

  test('ItemsRequested: Loading → Success', () async {
    final bloc = ItemsBloc(repo: ItemsRepo(client: client()));
    bloc.add(ItemsRequested());
    await expectLater(bloc.stream,
        emitsInOrder([isA<ItemsLoading>(), isA<ItemsSuccess>()]));
    await bloc.close();
  });

  test('ItemDetailRequested: Loading → DetailSuccess', () async {
    final bloc = ItemsBloc(repo: ItemsRepo(client: client()));
    bloc.add(ItemDetailRequested(1));
    await expectLater(bloc.stream,
        emitsInOrder([isA<ItemDetailLoading>(), isA<ItemDetailSuccess>()]));
    await bloc.close();
  });
}
