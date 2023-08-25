import 'package:flutter/material.dart';
import 'package:lebussd/models/model_cart.dart';
import 'package:lebussd/screen_home.dart';
import 'package:lebussd/singleton.dart';

import 'colors.dart';

class ScreenCart extends StatefulWidget {
  @override
  _ScreenCart createState() => _ScreenCart();
}

class _ScreenCart extends State<ScreenCart> {
  double _total = 0;

  _ScreenCart() {
    Singleton().listOfCart.forEach((element) {
      _total += element.price;
    });
  }
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            if (_selectedIndex != index) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                if (index == 0) {
                  return ScreenHome();
                } else {
                  return ScreenCart();
                }
              }));
            }
          });
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black,
        items: Singleton().listOfBottomNavItems,
        currentIndex: _selectedIndex,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(50))),
            minimumSize: MaterialStateProperty.all<Size>(
                Size(MediaQuery.of(context).size.width - 50, 50)),
          ),
          child: Text(
              'Pay \$${_total.toStringAsFixed(2)} + \$0.16 Transfer Fee',
              style: TextStyle(fontSize: 17)),
        ),
      ),
      appBar: AppBar(
        title: Text('Cart', style: Theme.of(context).textTheme.displayLarge),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
          itemCount: Singleton().listOfCart.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.only(top: 40),
                child: item(Singleton().listOfCart[index]));
          }),
    );
  }

  Widget item(ModelCart modelCart) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Image(
              image: AssetImage(modelCart.image),
              fit: BoxFit.fill,
            )),
        Column(children: [
          // Text("${modelCart.bundle}"),
          // const Text('USSD Bundle'),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text('\$${modelCart.price}'),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            verticalDirection: VerticalDirection.down,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (modelCart.quantity == 1) {
                        setState(() {
                          Singleton().listOfBundle.forEach((element) {
                            if (element.bundle == modelCart.bundle) {
                              setState(() {
                                element.isOrdered = false;
                              });
                            }
                          });
                          Singleton().listOfCart.remove(modelCart);
                        });
                      } else {
                        modelCart.quantity -= 1;
                      }
                      _total -= modelCart.price;
                    });
                  },
                  icon: const Icon(
                    Icons.remove_circle,
                  )),
              Text('${modelCart.quantity}'),
              IconButton(
                  onPressed: () {
                    setState(() {
                      modelCart.quantity += 1;
                      _total += modelCart.price;
                    });
                  },
                  icon: Icon(Icons.add_box_rounded)),
            ],
          )
        ])
      ],
    );
  }
}
