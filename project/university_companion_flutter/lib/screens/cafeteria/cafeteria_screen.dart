import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/meal.dart';
import 'package:university_companion/providers/cafeteria_provider.dart';
import 'package:university_companion/screens/cafeteria/meal_detail_screen.dart';
import 'package:university_companion/widgets/error_view.dart';
import 'package:university_companion/widgets/loading_view.dart';

class CafeteriaScreen extends ConsumerStatefulWidget {
  const CafeteriaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends ConsumerState<CafeteriaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafeteria Menu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Breakfast'),
            Tab(text: 'Lunch'),
            Tab(text: 'Dinner'),
          ],
        ),
      ),
      body: mealsAsync.when(
        data: (meals) {
          final breakfastMeals = meals.where((meal) => meal.mealType == 'breakfast').toList();
          final lunchMeals = meals.where((meal) => meal.mealType == 'lunch').toList();
          final dinnerMeals = meals.where((meal) => meal.mealType == 'dinner').toList();
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMealList(breakfastMeals),
              _buildMealList(lunchMeals),
              _buildMealList(dinnerMeals),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (error, stackTrace) => ErrorView(
          message: 'Failed to load cafeteria menu',
          onRetry: () => ref.refresh(mealsProvider),
        ),
      ),
    );
  }
  
  Widget _buildMealList(List<Meal> meals) {
    if (meals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_meals,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No meals available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailScreen(meal: meal),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    meal.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        ),
                      );
                    },
                  ),
                ),
                
                // Meal Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              meal.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(
                            '\$${meal.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meal.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildTag(context, meal.isVegetarian ? 'Vegetarian' : 'Non-Veg', 
                            meal.isVegetarian ? Colors.green : Colors.red),
                          const SizedBox(width: 8),
                          if (meal.isGlutenFree)
                            _buildTag(context, 'Gluten-Free', Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MealDetailScreen(meal: meal),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Pre-Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}