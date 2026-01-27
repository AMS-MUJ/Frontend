// import 'package:flutter/material.dart';
//
// class DropdownHintContent extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String? subtitle;
//
//   const DropdownHintContent({
//     super.key,
//     required this.icon,
//     required this.title,
//     this.subtitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20, color: Colors.grey.shade600),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//             if (subtitle != null) ...[
//               const SizedBox(height: 2),
//               Text(
//                 subtitle!,
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//             ],
//           ],
//         ),
//       ],
//     );
//   }
// }
