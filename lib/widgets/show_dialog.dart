import 'package:flutter/material.dart';
import 'package:realstore/constant/colors.dart';

void showMarketDialog(BuildContext context) {
  final items = [
    {
      //'image': 'assets/images/s11.png',
      'image': 'assets/images/productmarket.jpg',
      'text': 'Product Market',
      'route': '/market',
    },
    {
      'image': 'assets/images/ServiceMarket2.jpg',
      'text': 'Service Market',
      'route': '/service',
    },
    // {
    //   'image': 'assets/images/s6.png',
    //   'text': 'High End Market',
    //   'route': '/highend'
    // },
    {
      'image': 'assets/images/c3.jpg',
      'text': 'Social Market',
      'route': '/social',
    },
    {
      'image': 'assets/images/realestate4.png',
      'text': 'Real Estate',
      'route': '/realestate',
    },
  ];

  Color mainColor = getMainColor(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400, // Adjust dialog width as needed
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Afia Splendid',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pushNamed(context, item['route']!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(item['image']!, height: 60, width: 180),
                            // SizedBox(height: 8),
                            Text(
                              item['text']!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text(
                  'Close',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showMarketDialog11(BuildContext context) {
  final items = [
    {
      //'image': 'assets/images/s11.png',
      'image': 'assets/images/productmarket.jpg',
      'text': 'Product Market',
      'route': '/market',
    },
    {
      'image': 'assets/images/ServiceMarket2.jpg',
      'text': 'Service Market',
      'route': '/service',
    },
    {
      'image': 'assets/images/s6.png',
      'text': 'High End Market',
      'route': '/highend',
    },
    {
      'image': 'assets/images/realestate4.png',
      'text': 'Real Estate',
      'route': '/realestate',
    },
  ];

  Color mainColor = getMainColor(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 800, // Adjust dialog width as needed
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Afia Splendid',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pushNamed(context, item['route']!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              item['image']!,
                              height: 180,
                              width: 400,
                            ),
                            //SizedBox(height: 10),
                            Text(
                              item['text']!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text(
                  'Close',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showMarketDialog111(BuildContext context) {
  final items = [
    {
      //'image': 'assets/images/s11.png',
      'image': 'assets/images/productmarket.jpg',
      'text': 'Product Market',
      'route': '/market',
    },
    {
      'image': 'assets/images/ServiceMarket2.jpg',
      'text': 'Service Market',
      'route': '/service',
    },
    {
      'image': 'assets/images/s6.png',
      'text': 'High End Market',
      'route': '/highend',
    },
    {
      'image': 'assets/images/realestate4.png',
      'text': 'Real Estate',
      'route': '/realestate',
    },
  ];

  Color mainColor = getMainColor(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 800, // Adjust dialog width as needed
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Afia Splendid',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pushNamed(context, item['route']!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              item['image']!,
                              height: 180,
                              width: 500,
                            ),
                            // SizedBox(height: 8),
                            Text(
                              item['text']!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text(
                  'Close',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
