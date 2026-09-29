import 'package:flutter/material.dart';
//import 'package:the_splendid_market/productMarket/model/products/product.dart';

// class MarketCard extends StatelessWidget {
//   final String businessName;
//   final String businessLocation;
//   final String imageAsset;
//   final Function onTap;
//   final List<Product> products;

//   const MarketCard({
//     super.key,
//     required this.businessName,
//     required this.businessLocation,
//     required this.imageAsset,
//     required this.onTap,
//     required this.products,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         onTap();
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             image: DecorationImage(
//               image: AssetImage(imageAsset),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Business Name Positioned at the Top
//               Positioned(
//                 top: 8,
//                 left: 8,
//                 right: 8,
//                 child: Container(
//                   color: Colors.black54,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Center(
//                     child: Text(
//                       businessName,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ),
//               // GridView of Containers Positioned in the Center (2x2)
//               Positioned(
//                 top: 40,
//                 left: 8,
//                 right: 8,
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 4.0,
//                   mainAxisSpacing: 4.0,
//                   physics: NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   children: List.generate(4, (index) {
//                     final product = products.isNotEmpty
//                         ? products[index % products.length]
//                         : null;

//                     return Container(
//                       height: 160,
//                       decoration: BoxDecoration(
//                         color: Colors.black54,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             height: 45,
//                             width: 70,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image(
//                                 image: product != null && product.image != null
//                                     ? NetworkImage(product.image!)
//                                     : AssetImage('assets/images/s1.jpg')
//                                         as ImageProvider,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 3),
//                           Text(
//                             product != null
//                                 ? (product.name!.length > 15
//                                     ? product.name!.substring(0, 15) + '...'
//                                     : product.name!)
//                                 : '',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 8,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               // Business Location Positioned at the Bottom
//               Positioned(
//                 bottom: 8,
//                 left: 8,
//                 right: 8,
//                 child: Container(
//                   color: Colors.black54,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Center(
//                     child: Text(
//                       businessLocation,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         color: Colors.white,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class MarketCard extends StatelessWidget {
  final String businessName;
  final String businessLocation;
  final String productImage;
  final String productName;
  final double productPrice;
  final Function onTap;

  const MarketCard({
    super.key,
    required this.businessName,
    required this.businessLocation,
    required this.productImage,
    required this.productName,
    required this.productPrice,
    required this.onTap,
  });

  String formatPrice(double price) {
    // Convert the price to an integer and then to a string
    String priceString = price.toStringAsFixed(0);

    // Use a regular expression to add commas
    RegExp regExp = RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))');
    String formattedPrice =
        priceString.replaceAllMapped(regExp, (Match m) => ',');

    return formattedPrice;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Product Image Section
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(productImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Product and Business Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Product Name
                    Text(
                      productName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    // Product Price
                    // In your Text widget
                    Text(
                      '₦${formatPrice(productPrice)}',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 2),
                    // Business Name
                    Text(
                      businessName,
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    // Business Location
                    Text(
                      businessLocation,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarketCard1 extends StatelessWidget {
  final String businessName;
  final String businessLocation;
  final String productImage;
  final String productName;
  final double productPrice;
  final Function onTap;

  const MarketCard1({
    super.key,
    required this.businessName,
    required this.businessLocation,
    required this.productImage,
    required this.productName,
    required this.productPrice,
    required this.onTap,
  });

  String formatPrice(double price) {
    // Convert the price to an integer and then to a string
    String priceString = price.toStringAsFixed(0);

    // Use a regular expression to add commas
    RegExp regExp = RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))');
    String formattedPrice =
        priceString.replaceAllMapped(regExp, (Match m) => ',');

    return formattedPrice;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Product Image Section
              Container(
                height: 120,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(productImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Product and Business Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      productName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Product Price
                    Text(
                      '₦${formatPrice(productPrice)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                    // Business Name
                    Text(
                      businessName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Business Location
                    Text(
                      businessLocation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarketCard2 extends StatelessWidget {
  final String businessName;
  final String businessLocation;
  final String productImage;
  final String productName;
  final double productPrice;
  final Function onTap;

  const MarketCard2({
    super.key,
    required this.businessName,
    required this.businessLocation,
    required this.productImage,
    required this.productName,
    required this.productPrice,
    required this.onTap,
  });

  String formatPrice(double price) {
    // Convert the price to an integer and then to a string
    String priceString = price.toStringAsFixed(0);

    // Use a regular expression to add commas
    RegExp regExp = RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))');
    String formattedPrice =
        priceString.replaceAllMapped(regExp, (Match m) => ',');

    return formattedPrice;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Product Image Section
              Container(
                height: 150,
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(productImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Product and Business Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      productName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Product Price
                    Text(
                      '₦${formatPrice(productPrice)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    // Business Name
                    Text(
                      businessName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Business Location
                    Text(
                      businessLocation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class MarketCard1 extends StatelessWidget {
//   final String businessName;
//   final String businessLocation;
//   final String imageAsset;
//   final Function onTap;
//   final List<Product> products;

//   const MarketCard1({
//     super.key,
//     required this.businessName,
//     required this.businessLocation,
//     required this.imageAsset,
//     required this.onTap,
//     required this.products,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         onTap();
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             image: DecorationImage(
//               image: AssetImage(imageAsset),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Business Name Positioned at the Top
//               Positioned(
//                 top: 8,
//                 left: 8,
//                 right: 8,
//                 child: Container(
//                   color: Colors.black54,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Center(
//                     child: Text(
//                       businessName,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ),
//               // GridView of Containers Positioned in the Center (2x2)
//               Positioned(
//                 top: 40,
//                 left: 8,
//                 right: 8,
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 4.0,
//                   mainAxisSpacing: 4.0,
//                   physics: NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   children: List.generate(4, (index) {
//                     final product = products.isNotEmpty
//                         ? products[index % products.length]
//                         : null;

//                     return Container(
//                       height: 160,
//                       decoration: BoxDecoration(
//                         color: Colors.black54,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             height: 75,
//                             width: 85,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image(
//                                 image: product != null && product.image != null
//                                     ? NetworkImage(product.image!)
//                                     : AssetImage('assets/images/s1.jpg')
//                                         as ImageProvider,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 3),
//                           Text(
//                             product != null
//                                 ? (product.name!.length > 15
//                                     ? product.name!.substring(0, 15) + '...'
//                                     : product.name!)
//                                 : '',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 8,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               // Business Location Positioned at the Bottom
//               Positioned(
//                 bottom: 8,
//                 left: 8,
//                 right: 8,
//                 child: Container(
//                   color: Colors.black54,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Center(
//                     child: Text(
//                       businessLocation,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         color: Colors.white,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MarketCard2 extends StatelessWidget {
//   final String businessName;
//   final String businessLocation;
//   final String imageAsset;
//   final Function onTap;
//   final List<Product> products;

//   const MarketCard2({
//     super.key,
//     required this.businessName,
//     required this.businessLocation,
//     required this.imageAsset,
//     required this.onTap,
//     required this.products,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         onTap();
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             image: DecorationImage(
//               image: AssetImage(imageAsset),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Business Name Positioned at the Top
//               Positioned(
//                 top: 8,
//                 left: 8,
//                 right: 8,
//                 child: Container(
//                   color: Colors.black54,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Center(
//                     child: Text(
//                       businessName,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ),
//               // GridView of Containers Positioned in the Center (2x2)
//               Positioned(
//                 top: 40,
//                 left: 8,
//                 right: 8,
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 4.0,
//                   mainAxisSpacing: 4.0,
//                   physics: NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   children: List.generate(4, (index) {
//                     final product = products.isNotEmpty
//                         ? products[index % products.length]
//                         : null;

//                     return Container(
//                       height: 160,
//                       decoration: BoxDecoration(
//                         color: Colors.black54,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             height: 95,
//                             width: double.infinity,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image(
//                                 image: product != null && product.image != null
//                                     ? NetworkImage(product.image!)
//                                     : AssetImage('assets/images/s1.jpg')
//                                         as ImageProvider,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 3),
//                           Text(
//                             product != null
//                                 ? (product.name!.length > 15
//                                     ? product.name!.substring(0, 15) + '...'
//                                     : product.name!)
//                                 : '',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 8,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               // Business Location Positioned at the Bottom
//               Positioned(
//                 bottom: 8,
//                 left: 8,
//                 right: 8,
//                 child: Container(
//                   color: Colors.black54,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Center(
//                     child: Text(
//                       businessLocation,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         color: Colors.white,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
