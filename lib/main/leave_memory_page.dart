import 'package:flutter/material.dart';

class LeaveMemoryPage extends StatefulWidget {
  final Map<String, dynamic> photo;

  const LeaveMemoryPage({super.key, required this.photo});

  @override
  State<LeaveMemoryPage> createState() => _LeaveMemoryPageState();
}

class _LeaveMemoryPageState extends State<LeaveMemoryPage> {
  final List<String> _questions = [
    "이 날 가장 기억에 남는 순간은 무엇인가요?",
    "이 사진을 찍을 당시 누구와 함께 있었나요?",
    "이 사진은 어떤 감정을 떠올리게 하나요?",
    "이 사진이 찍히기 직전이나 직후에 무엇을 하고 있었나요?",
    "이 순간에 대해 기억하고 싶은 것은 무엇인가요?"
  ];

  final Map<int, String> _responses = {}; // Store responses
  bool _isBookmarked = false;
  bool _isLiked = false;

  Future<void> _saveResponses() async {
    // Simulate saving responses
    print("Saved Responses: $_responses");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Your memory has been saved!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave a Memory"),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo and details
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photo['fileUrl']!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Questions
            for (int i = 0; i < _questions.length; i++) ...[
              Text(
                "Question ${i + 1}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                _questions[i],
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  _responses[i] = value; // Store response
                },
                decoration: InputDecoration(
                  hintText: "Type your answer here...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
            ],

            // Save button
            Center(
              child: ElevatedButton(
                onPressed: _saveResponses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}