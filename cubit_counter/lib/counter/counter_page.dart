import 'package:cubit_counter/counter/counter_cubit.dart';
import 'package:cubit_counter/counter/counter_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterCubit(0),
      child: BlocListener<CounterCubit, int>(
        child: const CounterView(),
        listener: (context, state) {
          if (state == 7) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SUIIIIII!'),
                duration: Duration(milliseconds: 300),
              ),
            );
          }
        },
      ),
    );
  }
}
