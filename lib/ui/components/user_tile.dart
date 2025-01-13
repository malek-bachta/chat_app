import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text; 
  final String? lastMessage; 
  final void Function()? onTap; 
  final Widget? trailing; 

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
    this.trailing,
    this.lastMessage,
  });

  String _sanitizeText(String input) {
    return input.replaceAll(RegExp(r'[^\w\s]'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final sanitizedName = _sanitizeText(text);
    final displayName = sanitizedName.isEmpty ? 'Unknown' : sanitizedName;
    final displayMessage = lastMessage ?? 'No messages yet';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                displayName[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Last message
                  Text(
                    displayMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
