import 'package:flutter/material.dart';
import '../../components/button.dart';
import '../../components/input_fields.dart';
import '../../components/tag_input.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';

class CreateJobScreen extends StatefulWidget {
  @override
  _CreateJobScreenState createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  List<String> _skills = [];

  void _createJob() async {
    if (_formKey.currentState!.validate()) {
      final jobData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'salary': _salaryController.text,
        'requirements': _requirementsController.text,
        'required_skills': _skills,
      };

      await FirebaseService().createJob(jobData);
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Job'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextField(
                  prefixIcon: Icon(Icons.title),
                  labelText: 'Job Title',
                  hintText: 'Enter job title',
                  textInputType: TextInputType.text,
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                  controller: _titleController,
                ),
                const SizedBox(height: 16),
                DefaultTextField(
                  prefixIcon: Icon(Icons.description),
                  labelText: 'Job Description',
                  hintText: 'Enter job description',
                  textInputType: TextInputType.multiline,
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                  controller: _descriptionController,
                ),
                const SizedBox(height: 16),
                DefaultTextField(
                  prefixIcon: Icon(Icons.attach_money),
                  labelText: 'Salary',
                  hintText: 'Enter salary (optional)',
                  textInputType: TextInputType.number,
                  validator: (value) => null,
                  controller: _salaryController,
                ),
                const SizedBox(height: 16),
                DefaultTextField(
                  prefixIcon: Icon(Icons.list),
                  labelText: 'Requirements',
                  hintText: 'Enter job requirements',
                  textInputType: TextInputType.text,
                  validator: (value) =>
                      value!.isEmpty ? 'Requirements are required' : null,
                  controller: _requirementsController,
                ),
                const SizedBox(height: 16),
                Text('Required Skills', style: headerText14()),
                const SizedBox(height: 10),
                TagInput(
                  initialTags: _skills,
                  onChanged: (tags) => _skills = tags,
                ),
                const SizedBox(height: 24),
                DefaultButton(
                  onPressed: _createJob,
                  labelText: 'Create Job',
                  textStyle: headerText16(),
                  backgroundColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
