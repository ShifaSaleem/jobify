import 'package:flutter/material.dart';

class TagInput extends StatefulWidget {
  final List<String> initialTags;
  final ValueChanged<List<String>> onChanged;

  const TagInput({Key? key, required this.initialTags, required this.onChanged}) : super(key: key);

  @override
  _TagInputState createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final TextEditingController _tagController = TextEditingController();
  late List<String> tags;

  @override
  void initState() {
    super.initState();
    tags = List.from(widget.initialTags);
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        widget.onChanged(tags);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
      widget.onChanged(tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: [
        ...tags.map((tag) => Chip(
          label: Text(tag),
          onDeleted: () => _removeTag(tag),
        )),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _tagController,
            decoration: InputDecoration(
              hintText: 'Add skill',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _addTag(_tagController.text.trim()),
              ),
            ),
            onSubmitted: (tag) => _addTag(tag),
          ),
        ),
      ],
    );
  }
}
