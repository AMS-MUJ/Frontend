import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LectureCardShimmer extends StatelessWidget {
  const LectureCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(width: double.infinity, height: 18),
              const SizedBox(height: 8),
              _bar(width: 120, height: 14),
              const SizedBox(height: 6),
              _bar(width: 80, height: 14),

              const Divider(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_iconText(), _iconText(), _iconText()],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_button(), _button(), _button()],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(width: width, height: height, color: Colors.white);
  }

  Widget _iconText() {
    return Row(
      children: [
        Container(width: 22, height: 22, color: Colors.white),
        const SizedBox(width: 6),
        Container(width: 60, height: 14, color: Colors.white),
      ],
    );
  }

  Widget _button() {
    return Container(width: 90, height: 36, color: Colors.white);
  }
}
