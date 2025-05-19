import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/entities/product.dart';
import 'package:komercia_app/features/products/presentation/providers/product_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/product_categories_provider.dart';

class ProductScreen extends ConsumerStatefulWidget {
  final int idProduct;

  const ProductScreen({super.key, required this.idProduct});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioCompraController;
  late TextEditingController _precioVentaController;

  int? selectedCategoriaId;
  bool _inicializado = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider(widget.idProduct));
    final categoriasState = ref.watch(productCategoriesProvider);

    final producto = productState.producto;

    if (productState.isLoading ||
        categoriasState.isLoading ||
        producto == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Inicializa controllers solo una vez
    if (!_inicializado) {
      _nombreController = TextEditingController(text: producto.nombreProducto);
      _descripcionController =
          TextEditingController(text: producto.descripcionProducto ?? '');
      _precioCompraController =
          TextEditingController(text: producto.precioCompra?.toString() ?? '');
      _precioVentaController =
          TextEditingController(text: producto.precioVenta?.toString() ?? '');
      selectedCategoriaId = producto.idCategoria;
      _inicializado = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _precioCompraController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio Compra'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _precioVentaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio Venta'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: selectedCategoriaId,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categoriasState.productCategories!
                    .map((cat) => DropdownMenuItem<int>(
                          value: cat.idCategoria,
                          child: Text(cat.nombreCategoria),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedCategoriaId = value);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedProduct = Product(
                      idProducto: widget.idProduct,
                      codigoProducto: "",
                      nombreProducto: _nombreController.text,
                      descripcionProducto: _descripcionController.text,
                      precioCompra:
                          double.tryParse(_precioCompraController.text),
                      precioVenta: double.tryParse(_precioVentaController.text),
                      idCategoria: selectedCategoriaId,
                    );

                    await ref
                        .read(productProvider(widget.idProduct).notifier)
                        .updateProduct(updatedProduct);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Producto actualizado')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
