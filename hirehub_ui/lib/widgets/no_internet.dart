import 'package:flutter/material.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/background/no_internet.jpg',width: 400,),
          const SizedBox(height: 20,),
          Text('No Internet Connection',style: size.width > 300 ? Theme.of(context).textTheme.titleLarge : size.width < 250 ? Theme.of(context).textTheme.titleSmall  : Theme.of(context).textTheme.titleMedium,)
        ],
      ),
    );
  }
}