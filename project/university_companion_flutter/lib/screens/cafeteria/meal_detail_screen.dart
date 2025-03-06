import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/meal.dart';
import 'package:university_companion/providers/cart_provider.dart';
import 'package:university_companion/screens/cafeteria/checkout_screen.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final Meal meal;

  const MealDetailScreen({
    Key? key,
    required this.meal,
  }) : super(key: key);

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  int _quantity = 1;
  String? _selectedSize;
  List<String> _selectedExtras = [];

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.meal.availableSizes.isNotEmpty ? widget.meal.availableSizes.first : null;
  }

  double get _totalPrice {
    double basePrice = widget.meal.price;
    
    // Add size price
    if (_selectedSize == 'Medium') {
      basePrice += 1.0;
    } else if (_selectedSize == 'Large') {
      basePrice += 2.0;
    }
    
    // Add extras price
    basePrice += _selectedExtras.length * 0.5;
    
    return basePrice * _quantity;
  }

  void _addToCart() {
    ref.read(cartProvider.notifier).addToCart(
      widget.meal,
      _quantity,
      _selectedSize,
      _selectedExtras,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.meal.name} added to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CheckoutScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.meal.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 64),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Meal Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.meal.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        '\$${widget.meal.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Tags
                  Row(
                    children: [
                      _buildTag(context, widget.meal.isVegetarian ? 'Vegetarian' : 'Non-Veg', 
                        widget.meal.isVegetarian ? Colors.green : Colors.red),
                      const SizedBox(width: 8),
                      if (widget.meal.isGlutenFree)
                        _buildTag(context, 'Gluten-Free', Colors.orange),
                      const SizedBox(width: 8),
                      _buildTag(context, '${widget.meal.calories} cal', Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.meal.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // Nutritional Info
                  Text(
                    'Nutritional Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionItem('Calories', '${widget.meal.calories}'),
                      _buildNutritionItem('Protein', '${widget.meal.protein}g'),
                      _buildNutritionItem('Carbs', '${widget.meal.carbs}g'),
                      _buildNutritionItem('Fat', '${widget.meal.fat}g'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Size Selection
                  if (widget.meal.availableSizes.isNotEmpty) ...[
                    Text(
                      'Size',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.meal.availableSizes.map((size) {
                        return ChoiceChip(
                          label: Text(size),
                          selected: _selectedSize == size,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSize = selected ? size : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Extras
                  if (widget.meal.availableExtras.isNotEmpty) ...[
                    Text(
                      'Extras (+\$0.50 each)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...widget.meal.availableExtras.map((extra) {
                      return CheckboxListTile(
                        title: Text(extra),
                        value: _selectedExtras.contains(extra),
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedExtras.add(extra);
                            } else {
                              _selectedExtras.remove(extra);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Quantity
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Total and Add to Cart
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Price'),
                            Text(
                              '\$${_totalPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addToCart,
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
  
  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}