import 'dart:io';
import 'package:app_api/app/data/api.dart';
import 'package:app_api/app/data/sqlite.dart';
import 'package:app_api/app/model/cart.dart';
import 'package:app_api/app/model/product.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeBuilder extends StatefulWidget {
  const HomeBuilder({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeBuilder> createState() => _HomeBuilderState();
}

class _HomeBuilderState extends State<HomeBuilder> {
  final DatabaseHelper _databaseService = DatabaseHelper();

  Future<List<ProductModel>> _getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await APIRepository().getListAdmin(
      prefs.getString('token').toString(),
    );
  }

  Future<void> _onSave(ProductModel pro) async {
    _databaseService.insertProduct(Cart(
      productID: pro.id,
      name: pro.name,
      des: pro.description,
      price: pro.price,
      img: pro.imageUrl,
      count: 1,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ProductModel>>(
        future: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Column(
              children: [
                _buildCarouselBanner(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final itemProduct = snapshot.data![index];
                        return itemGridView(itemProduct);
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }

  Widget _buildCarouselBanner() {
    final List<String> imageList = [
      'https://hoanghamobile.com/tin-tuc/wp-content/uploads/2020/07/banner-trang-tin-sale.jpg', // Thay thế bằng các URL hình ảnh thực tế
      'https://d30qyzivworh94.cloudfront.net/2020/12/f261e566-2258-49df-a38b-2768be71f01e.jpg',
      'https://phukiendienthoaidanang.vn/wp-content/uploads/2020/08/phu-kien-dien-thoai.jpg',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
      ),
      items: imageList.map((item) => Container(
        margin: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              Image.network(item, fit: BoxFit.cover, width: 1000.0),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget itemGridView(ProductModel productModel) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Image.network(
                  productModel.imageUrl ?? '',
                  height: 90,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                productModel.name != null
                    ? (productModel.name!.length > 20
                        ? '${productModel.name!.substring(0, 15)}...'
                        : productModel.name)
                    : '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                NumberFormat('###,###.###₫').format(productModel.price),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  _onSave(productModel);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${productModel.name} added to cart.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(15.0),
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 244, 222, 54),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: const Text(
                '15%',
                style: TextStyle(
                  color: Color.fromARGB(255, 26, 25, 25),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: FavoriteButton(),
          ),
        ],
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      },
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : Colors.grey,
      ),
    );
  }
}
