import 'package:flutter/material.dart';

void showMarketDialog1(BuildContext context) {
  final items = [
    {
      'image': 'assets/images/productmarket.jpg',
      'text': 'Product Shop',
      'route': '/login',
    },
    {
      'image': 'assets/images/ServiceMarket2.jpg',
      'text': 'Service Shop',
      'route': '/loginS',
    },
    {
      'image': 'assets/images/s6.png',
      'text': 'High End Shop',
      'route': '/loginH',
    },
    {
      'image': 'assets/images/realestate4.png',
      'text': 'Real Estate Shop',
      'route': '/loginR',
    },
  ];

  //Color mainColor = getMainColor(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor:
            Colors.transparent, // Make the dialog background transparent
        child: Container(
          width: 400, // Adjust dialog width as needed
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            //color: Colors.black.withOpacity(0.5), // Semi-transparent background
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage('assets/images/dark1.jpg'),
              // Add your background image here
              fit: BoxFit.cover,
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Own a',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                item['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 0, // Position text at the bottom
                              left: 0,
                              right: 0,
                              child: Container(
                                width: 20, // Set a specific width for the text container
                                padding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ), // Reduced vertical padding
                                decoration: BoxDecoration(
                                  color:
                                      Colors.black54, // Background for the text
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ), // Rounded top corners
                                ),
                                child: Text(
                                  item['text']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                  backgroundColor: Colors.black,
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

void showMarketDialog10(BuildContext context) {
  final items = [
    {
      //'image': 'assets/images/s11.png',
      'image': 'assets/images/productmarket.jpg',
      'text': 'Product Shop',
      'route': '/login',
    },
    {
      'image': 'assets/images/ServiceMarket2.jpg',
      'text': 'Service Shop',
      'route': '/loginS',
    },
    {
      'image': 'assets/images/s6.png',
      'text': 'High End Shop',
      'route': '/loginH',
    },
    {
      'image': 'assets/images/realestate4.png',
      'text': 'Real Estate Shop',
      'route': '/loginR',
    },
  ];

  //Color mainColor = getMainColor(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 800, // Adjust dialog width as needed
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            //color: Colors.black.withOpacity(0.5), // Semi-transparent background
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage('assets/images/c2.jpg'),
              // Add your background image here
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Own a',
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                item['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 0, // Position text at the bottom
                              left: 0,
                              right: 0,
                              child: Container(
                                width: 20, // Set a specific width for the text container
                                padding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ), // Reduced vertical padding
                                decoration: BoxDecoration(
                                  color:
                                      Colors.black54, // Background for the text
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ), // Rounded top corners
                                ),
                                child: Text(
                                  item['text']!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                  backgroundColor: Colors.black,
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

void showMarketDialog110(BuildContext context) {
  final items = [
    {
      //'image': 'assets/images/s11.png',
      'image': 'assets/images/productmarket.jpg',
      'text': 'Product Shop',
      'route': '/login',
    },
    {
      'image': 'assets/images/ServiceMarket2.jpg',
      'text': 'Service Shop',
      'route': '/loginS',
    },
    {
      'image': 'assets/images/s6.png',
      'text': 'High End Shop',
      'route': '/loginH',
    },
    {
      'image': 'assets/images/realestate4.png',
      'text': 'Real Estate Shop',
      'route': '/loginR',
    },
  ];

  //Color mainColor = getMainColor(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 800, // Adjust dialog width as needed
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            //color: Colors.black.withOpacity(0.5), // Semi-transparent background
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage('assets/images/c2.jpg'),
              // Add your background image here
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Own a',
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                item['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 0, // Position text at the bottom
                              left: 0,
                              right: 0,
                              child: Container(
                                width: 20, // Set a specific width for the text container
                                padding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ), // Reduced vertical padding
                                decoration: BoxDecoration(
                                  color:
                                      Colors.black54, // Background for the text
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ), // Rounded top corners
                                ),
                                child: Text(
                                  item['text']!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                  backgroundColor: Colors.black,
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
