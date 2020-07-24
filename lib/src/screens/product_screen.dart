import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery/src/models/product.dart';
import 'package:gallery/src/providers/product_provider.dart';
import 'package:gallery/src/utils/utils.dart';
import 'package:image_picker/image_picker.dart';

class ProductScreen extends StatefulWidget {
  ProductScreen({Key key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _productoProvider = ProductoProvider();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  Product _product = new Product();
  bool _saving = false;
  File _photo;

  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context).settings.arguments;
    if (product != null) {
      _product = product;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: _actions(),
      ),
      body: _body(),
    );
  }

  List<Widget> _actions() {
    return [
      IconButton(
        icon: Icon(Icons.photo_size_select_actual),
        onPressed: () => _getPhoto(ImageSource.gallery),
      ),
      IconButton(
        icon: Icon(Icons.camera_alt),
        onPressed: () => _getPhoto(ImageSource.camera),
      ),
    ];
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _viewPhoto(),
              SizedBox(height: 20.0),
              _name(),
              SizedBox(height: 10.0),
              _price(),
              _available(),
              SizedBox(height: 40.0),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewPhoto() {
    if (_product.photoUrl != null) {
      return FadeInImage(
        image: NetworkImage(_product.photoUrl),
        placeholder: AssetImage('assets/img/jar-loading.gif'),
        height: 300.0,
        width: double.infinity,
        fit: BoxFit.cover,
      );
      ;
    } else {
      final path = _photo?.path ?? 'assets/img/no-image.png';
      return Image(
        image: AssetImage(path),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _name() {
    return TextFormField(
      initialValue: _product.title,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Producto',
      ),
      onSaved: (value) => _product.title = value,
      validator: (value) {
        if (value.length < 4) {
          return 'Ingrese el number del producto';
        } else {
          return null;
        }
      },
    );
  }

  Widget _price() {
    return TextFormField(
      initialValue: '${_product.price}',
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: 'Precio',
      ),
      onSaved: (value) => _product.price = double.parse(value),
      validator: (value) => isNumeric(value) ? null : 'Solo numero',
    );
  }

  Widget _available() {
    return SwitchListTile(
      value: _product.available,
      onChanged: (value) => setState(() {
        _product.available = value;
      }),
    );
  }

  Widget _saveButton() {
    return RaisedButton.icon(
      padding: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      icon: Icon(Icons.save),
      label: Text('Save'),
      onPressed: _saving ? null : _submit,
    );
  }

  void _submit() async {
    final valid = _formKey.currentState.validate();
    if (!valid) {
      return;
    }

    _formKey.currentState.save();
    _saving = true;
    setState(() {});

    await _uploadPhoto();

    if (_product.id == null) {
      _saveProduct();
    } else {
      _updateProduct();
    }
  }

  void _saveProduct() async {
    final saved = await _productoProvider.addProduct(product: _product);
    final message = saved ? 'Producto guardado' : 'Error al guardar producto';
    _viewAlert(message, saved ? Colors.green : Colors.red);
    _navigateToHome(saved);
  }

  void _updateProduct() async {
    final updated = await _productoProvider.updateProduct(product: _product);
    final message =
        updated ? 'Producto actualizado' : 'Error al actualizar producto';
    _viewAlert(message, updated ? Colors.green : Colors.red);
    _navigateToHome(updated);
  }

  void _viewAlert(final String message, final Color color) {
    final snackbar = SnackBar(
      backgroundColor: color,
      content: Text('$message'),
      duration: Duration(seconds: 2),
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _navigateToHome(final bool navigate) {
    if (navigate) {
      Future.delayed(
        Duration(milliseconds: 1500),
        () => Navigator.pushNamedAndRemoveUntil(
          context,
          'home',
          (route) => false,
        ),
      );
    }
  }

  void _getPhoto(final ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      _product.photoUrl = null;
      setState(() {});
    }
  }

  Future<void> _uploadPhoto() async {
    if (_photo != null) {
      final url = await _productoProvider.uploadFile(_photo);
      if (url != null) {
        _product.photoUrl = url;
      }
    }
  }
}
