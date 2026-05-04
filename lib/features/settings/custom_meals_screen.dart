import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/custom_meals_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class CustomMealsScreen extends StatelessWidget {
  const CustomMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settingsCustomMealsLabel)),
      body: BlocBuilder<CustomMealsBloc, CustomMealsState>(
        builder: (context, state) {
          if (state is CustomMealsLoadingState || state is CustomMealsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CustomMealsLoadedState) {
            if (state.meals.isEmpty) {
              return Center(child: Text(S.of(context).customMealsEmptyLabel));
            }
            return ListView.builder(
              itemCount: state.meals.length,
              itemBuilder: (context, index) {
                final meal = state.meals[index];
                return ListTile(
                  title: Text(meal.name ?? ''),
                  subtitle: meal.brands != null ? Text(meal.brands!) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, meal),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MealEntity meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).customMealsDeleteConfirmTitle),
        content: Text(S.of(context).customMealsDeleteConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.of(context).dialogDeleteLabel),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<CustomMealsBloc>()
          .add(DeleteCustomMealEvent(meal.code ?? meal.name ?? ''));
    }
  }
}
