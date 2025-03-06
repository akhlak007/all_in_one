import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_companion/models/meal.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartItem {
  final Meal meal;
  final int quantity;
  final String? selectedSize;
  final List<String> selectedExtras;

  CartItem({
    required this.meal,
    required this.quantity,
    this.selectedSize,
    required this.selectedExtras,
  });

  double get totalPrice {
    double basePrice = meal.price;
    
    // Add size price
    if (selectedSize == 'Medium') {
      basePrice += 1.0;
    } else if (selectedSize == 'Large') {
      basePrice += 2.0;
    }
    
    // Add extras price
    basePrice += selectedExtras.length * 0.5;
    
    return basePrice * quantity;
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(
    Meal meal,
    int quantity,
    String? selectedSize,
    List<String> selectedExtras,
  ) {
    // Check if the meal is already in the cart
    final existingIndex = state.indexWhere((item) => 
      item.meal.id == meal.id && 
      item.selectedSize == selectedSize &&
      _areListsEqual(item.selectedExtras, selectedExtras)
    );

    if (existingIndex >= 0) {
      // Update existing item
      final existingItem = state[existingIndex];
      final updatedItem = CartItem(
        meal: existingItem.meal,
        quantity: existingItem.quantity + quantity,
        selectedSize: existingItem.selectedSize,
        selectedExtras: existingItem.selectedExtras,
      );
      
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      state = [
        ...state,
        CartItem(
          meal: meal,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedExtras: selectedExtras,
        ),
      ];
    }
  }

  void removeFromCart(int index) {
    state = [
      ...state.sublist(0, index),
      ...state.sublist(index + 1),
    ];
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeFromCart(index);
      return;
    }
    
    final item = state[index];
    final updatedItem = CartItem(
      meal: item.meal,
      quantity: quantity,
      selectedSize: item.selectedSize,
      selectedExtras: item.selectedExtras,
    );
    
    state = [
      ...state.sublist(0, index),
      updatedItem,
      ...state.sublist(index + 1),
    ];
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0, (total, item) => total + item.totalPrice);
  }
  
  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    
    final sortedList1 = List<String>.from(list1)..sort();
    final sortedList2 = List<String>.from(list2)..sort();
    
    for (int i = 0; i < sortedList1.length; i++) {
      if (sortedList1[i] != sortedList2[i]) return false;
    }
    
    return true;
  }
}