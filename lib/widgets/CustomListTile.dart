import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final int id;
  final String date;
  final String work;
  final String isPaid;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePaid;

  CustomListTile({
    required this.id,
    required this.date,
    required this.work,
    required this.isPaid,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePaid,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? colorScheme.onSurface
        : Colors.black;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context)
                  .primaryColor), // Use colorScheme divider color
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor, // Use theme card color
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            children: [
              Text(
                "ID: $id",
                style: TextStyle(
                  fontSize: 14,
                  color: textColor, // Use textColor for ID
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                work,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  // Use theme primary color for work
                ),
              ),
            ],
          ),
          subtitle: Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .color, // Use theme caption color
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onTogglePaid,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPaid == 'Paid' ? Colors.green : Colors.red,
                  ),
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Delete'),
                        onTap: onDelete,
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
