import 'package:flutter/material.dart';

class PaymentTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function()? onTap;
  final bool isSelected;

  const PaymentTypeCard(
      {super.key,
      required this.icon,
      required this.label,
      this.onTap,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 3 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.black12,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.black26,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 28, color: isSelected ? Colors.blue : Colors.black87),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.blue : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
