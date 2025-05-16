import 'package:dio/dio.dart';
import 'package:komercia_app/config/config.dart';
import 'package:komercia_app/features/auth/domain/entities/permission.dart';
import 'package:komercia_app/features/auth/domain/entities/user.dart';
import 'package:komercia_app/features/home/domain/domain.dart';
import 'package:komercia_app/features/home/infrastructure/mappers/permission_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
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

    final List<Menu> menus = [];
    menus.addAll([
      Menu(
          idMenu: 2,
          codigoMenu: "0002",
          nombreMenu: "Registrar venta",
          descripcionMenu: "Registrar venta",
          rutaMenu: "/new_sale",
          icono: "analytics_rounded"),
      Menu(
          idMenu: 3,
          codigoMenu: "0003",
          nombreMenu: "Inventario",
          descripcionMenu: "Inventario",
          rutaMenu: "/products",
          icono: "inventory")
    ]);

    return menus;
  }

  @override
  Future<List<Menu>> getMenusTabBarByUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final List<Menu> menus = [];
    menus.addAll([
      Menu(
          idMenu: 1,
          codigoMenu: "0001",
          nombreMenu: "Inicio",
          descripcionMenu: "Inicio",
          rutaMenu: "/",
          icono: "home"),
      Menu(
          idMenu: 4,
          codigoMenu: "0004",
          nombreMenu: "Balance",
          descripcionMenu: "Balance",
          rutaMenu: "/balance",
          icono: "balance"),
      Menu(
          idMenu: 3,
          codigoMenu: "0003",
          nombreMenu: "Inventario",
          descripcionMenu: "Inventario",
          rutaMenu: "/products",
          icono: "image_search_rounded")
    ]);

    return menus;
  }

  @override
  Future<List<Menu>> getMenusSideBarByUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final List<Menu> menus = [];
    menus.addAll([
      Menu(
          idMenu: 1,
          codigoMenu: "0001",
          nombreMenu: "Inicio",
          descripcionMenu: "Inicio",
          rutaMenu: "/",
          icono: "home"),
      Menu(
          idMenu: 4,
          codigoMenu: "0004",
          nombreMenu: "Balance",
          descripcionMenu: "Balance",
          rutaMenu: "/balance",
          icono: "balance"),
      Menu(
          idMenu: 3,
          codigoMenu: "0003",
          nombreMenu: "Inventario",
          descripcionMenu: "Inventario",
          rutaMenu: "/products",
          icono: "image_search_rounded")
    ]);
    return menus;
  }

  @override
  Future<List<Permission>> permissions() async {
    int idApplication = 1;
    final response =
        await dioClient.dio.get('/auth/get_permissions/$idApplication');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<Permission> permissions = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _permission in responseMain.data ?? []) {
      permissions.add(PermissionMapper.jsonToEntity(_permission));
    }
    permissions.add(Permission(
        idMenu: 0,
        nombreMenu: "Inicio",
        descripcionMenu: "Inicio",
        rutaMenu: "/home",
        icono: "home",
        acciones: []));

    return permissions;
  }
}
