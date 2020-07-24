import 'package:flutter/material.dart';
import 'package:gallery/src/models/product.dart';
import 'package:gallery/src/providers/product_provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productoProvider = new ProductoProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      body: _productsBuilder(context),
      floatingActionButton: _addProduct(context),
    );
  }

  Widget _addProduct(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(Icons.add),
      onPressed: () => Navigator.pushNamed(context, 'product'),
    );
  }

  Widget _productsBuilder(BuildContext context) {
    return FutureBuilder(
      future: _productoProvider.getProductos(),
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        if (snapshot.hasData) {
          return _products(snapshot.data);
        } else {
          return _loadingIndicator(context);
        }
      },
    );
  }

  Widget _loadingIndicator(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _products(final List<Product> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (BuildContext contex, i) => _product(contex, products[i]),
    );
  }

  Widget _product(BuildContext context, final Product product) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.redAccent,
      ),
      onDismissed: (DismissDirection direction) => _deleteProduct(product),
      child: _productCard(product),
    );
  }

  Widget _productCard(final Product product) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        child: Card(
          child: Column(
            children: <Widget>[
              _productImage(product),
              ListTile(
                title: Text(
                  '${product.title}',
                  style: TextStyle(fontSize: 20.0),
                ),
                subtitle: Text(
                  '${product.price}',
                  style: TextStyle(fontSize: 18.0),
                ),
              )
            ],
          ),
        ),
        onTap: () => _onTapProduct(context, product),
      ),
    );
  }

  Widget _productImage(final Product product) {
    if (product.photoUrl == null) {
      return Image(image: AssetImage('assets/img/no-image.png'));
    } else {
      return FadeInImage(
        image: NetworkImage(product.photoUrl),
        placeholder: AssetImage('assets/img/jar-loading.gif'),
        height: 300.0,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  void _deleteProduct(final Product product) async {
    await _productoProvider.deleteProduct(
      productId: product.id,
    );

    setState(() {});
  }

  void _onTapProduct(BuildContext context, final Product product) {
    Navigator.pushNamed(context, 'product', arguments: product);
  }
}
