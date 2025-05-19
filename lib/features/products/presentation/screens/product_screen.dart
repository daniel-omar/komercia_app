import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/home/presentation/providers/menu_provider.dart';
import 'package:komercia_app/features/products/domain/entities/product.dart';
import 'package:komercia_app/features/products/presentation/providers/product_form_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/product_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/product_categories_provider.dart';
import 'package:komercia_app/features/shared/widgets/custom_filled_button.dart';
import 'package:komercia_app/features/shared/widgets/custom_text_area.dart';
import 'package:komercia_app/features/shared/widgets/custom_text_form_field.dart';

class ProductScreen extends ConsumerStatefulWidget {
  final int idProduct;

  const ProductScreen({super.key, required this.idProduct});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final _formKey = GlobalKey<FormState>();

  int? selectedCategoriaId;

  @override
  void dispose() {
    super.dispose();
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final productFormState = ref.watch(productFormProvider(widget.idProduct));
    final categoriasState = ref.watch(productCategoriesProvider);

    if (productFormState.isLoading || categoriasState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (productFormState.idProduct == 0) {
      // Asegúrate de que esto se ejecute fuera del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pop(); // o context.pop() si usas GoRouter
          showSnackbar(context, 'Producto no encontrado');
        }
      });
    }

    ref.listen<ProductState>(productProvider(widget.idProduct), (prev, next) {
      if (!next.isLoading) {
        if (next.errorMessage.isNotEmpty) {
          showSnackbar(context, next.errorMessage);
        } else {
          Navigator.of(context).pop();
          // Navegar o hacer otra acción
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Producto actualizado con éxito'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3), // Duración del SnackBar
                behavior: SnackBarBehavior.floating),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextFormField(
                isTopField: true,
                label: 'Nombre',
                initialValue: productFormState.name.value,
                onChanged: ref
                    .read(productFormProvider(widget.idProduct).notifier)
                    .onNameChange,
                errorMessage: productFormState.name.errorMessage,
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                isTopField: true,
                keyboardType: TextInputType.number,
                label: 'Precio compra',
                initialValue: productFormState.pursharsePrice.value.toString(),
                onChanged: ref
                    .read(productFormProvider(widget.idProduct).notifier)
                    .onPurcharsePriceChanged,
                errorMessage: productFormState.pursharsePrice.errorMessage,
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                isTopField: true,
                keyboardType: TextInputType.number,
                label: 'Precio venta',
                initialValue: productFormState.salePrice.value.toString(),
                onChanged: ref
                    .read(productFormProvider(widget.idProduct).notifier)
                    .onSalePriceChanged,
                errorMessage: productFormState.salePrice.errorMessage,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: productFormState.idCategory,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categoriasState.productCategories!
                    .map((cat) => DropdownMenuItem<int>(
                          value: cat.idCategoria,
                          child: Text(
                            cat.nombreCategoria,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ))
                    .toList(),
                onChanged: ref
                    .read(productFormProvider(widget.idProduct).notifier)
                    .onCategoryChanged,
              ),
              const SizedBox(height: 20),
              const Text(
                'Descripción',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              CustomTextArea(
                isTopField: true,
                label: '',
                minLine: 3,
                maxLine: null,
                initialValue: productFormState.description.value,
                onChanged: ref
                    .read(productFormProvider(widget.idProduct).notifier)
                    .onDescriptionChanged,
                // errorMessage: productFormState.description.errorMessage,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ref
              .read(menusProvider.notifier)
              .tienePermisoEdicion("/products", "Modificar")
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: CustomFilledButton(
                    text: productFormState.isPosting
                        ? 'Guardando...'
                        : 'Modificar',
                    buttonColor: Colors.black,
                    onPressed: productFormState.isPosting
                        ? null
                        : ref
                            .read(
                                productFormProvider(widget.idProduct).notifier)
                            .onFormUpdateSubmit),
              ),
            )
          : null,
    );
  }
}
