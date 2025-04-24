import 'package:dio/dio.dart';
import 'package:komercia_app/config/config.dart';
import 'package:komercia_app/features/home/domain/domain.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';
import 'package:flutter/material.dart';

import '../errors/menu_errors.dart';
import '../mappers/menu_mapper.dart';

class MenuDatasourceImpl extends MenuDatasource {
  late final dioClient = DioClient();

  MenuDatasourceImpl();

  @override
  Future<Menu> getMenuById(int idMenu) async {
    try {
      final response = await dioClient.dio.get('/menu/$idMenu');
      final product = MenuMapper.jsonToEntity(response.data);
      return product;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Menu>> getMenusByUser(int idUsuario) async {
    await Future.delayed(const Duration(milliseconds: 100));

    //final response = await dioClient.dio.get<List>('/permisos/$idUsuario');
    final List<Menu> menus = [];
    menus.addAll([
      Menu(
          idMenu: 1,
          codigoMenu: "0001",
          nombreMenu: "Materiales",
          descripcionMenu: "Materiales técnico",
          rutaMenu: "/materials",
          icono: Icons.image_search_rounded),
      Menu(
          idMenu: 2,
          codigoMenu: "0002",
          nombreMenu: "Ordenes",
          descripcionMenu: "Ordenes",
          rutaMenu: "/orders",
          icono: Icons.warehouse_rounded),
      // Menu(
      //     idMenu: 3,
      //     codigoMenu: "0003",
      //     nombreMenu: "Materiales",
      //     descripcionMenu: "Materiales técnico",
      //     rutaMenu: "/materials",
      //     icono: Icons.warehouse_outlined),
    ]);
    // for (final product in response.data ?? []) {
    //   products.add(MenuMapper.jsonToEntity(product));
    // }

    return menus;
  }
}
