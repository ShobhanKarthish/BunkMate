import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/ui_constants.dart';
import '../models/subject.dart';
import '../models/schedule_item.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final Subject? subject;
  
  const AddEditSubjectScreen({super.key, this.subject});

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _minAttendanceController = TextEditingController();
  
  String _selectedType = AppConstants.lecture;
  bool _isMonthlyCalculation = true;
  List<ScheduleItem> _schedule = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _nameController.text = widget.subject!.name;
      _minAttendanceController.text = widget.subject!.minAttendance.toString();
      _selectedType = widget.subject!.type;
      _isMonthlyCalculation = widget.subject!.isMonthlyCalculation;
      _schedule = List.from(widget.subject!.schedule);
    } else {
      _minAttendanceController.text = AppConstants.defaultMinAttendance.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject == null ? 'Add Subject' : 'Edit Subject'),
        actions: [
          TextButton(
            onPressed: _saveSubject,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(UIConstants.spacingM),
          children: [
            // Subject Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject name';
                }
                return null;
              },
            ),
            const SizedBox(height: UIConstants.spacingM),
            
            // Subject Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Subject Type',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.classTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(UIConstants.classTypeIcons[type] ?? Icons.school),
                      const SizedBox(width: UIConstants.spacingS),
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: UIConstants.spacingM),
            
            // Minimum Attendance
            TextFormField(
              controller: _minAttendanceController,
              decoration: const InputDecoration(
                labelText: 'Minimum Attendance (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter minimum attendance';
                }
                final percentage = double.tryParse(value);
                if (percentage == null || percentage < 0 || percentage > 100) {
                  return 'Please enter a valid percentage (0-100)';
                }
                return null;
              },
            ),
            const SizedBox(height: UIConstants.spacingM),
            
            // Calculation Type
            SwitchListTile(
              title: const Text('Monthly Calculation'),
              subtitle: Text(_isMonthlyCalculation 
                ? 'Attendance resets each month' 
                : 'Cumulative attendance for entire semester'),
              value: _isMonthlyCalculation,
              onChanged: (value) {
                setState(() {
                  _isMonthlyCalculation = value;
                });
              },
            ),
            const SizedBox(height: UIConstants.spacingL),
            
            // Schedule Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Schedule',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addScheduleItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Time'),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingS),
            
            // Schedule List
            if (_schedule.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.spacingL),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      Text(
                        'No schedule added yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(_schedule.map((item) => _buildScheduleItem(item)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(ScheduleItem item) {
    final dayName = AppConstants.daysOfWeek[item.dayOfWeek - 1];
    
    return Card(
      child: ListTile(
        leading: Icon(Icons.schedule),
        title: Text(dayName),
        subtitle: Text(item.time),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _schedule.remove(item);
            });
          },
        ),
      ),
    );
  }

  void _addScheduleItem() {
    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(
        onScheduleAdded: (scheduleItem) {
          setState(() {
            _schedule.add(scheduleItem);
          });
        },
      ),
    );
  }

  void _saveSubject() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_schedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one class time'),
        ),
      );
      return;
    }

    final subjectsBox = Hive.box<Subject>(AppConstants.subjectsBox);
    
    if (widget.subject == null) {
      // Create new subject
      final newSubject = Subject(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        type: _selectedType,
        minAttendance: double.parse(_minAttendanceController.text),
        schedule: _schedule,
        isMonthlyCalculation: _isMonthlyCalculation,
      );
      subjectsBox.add(newSubject);
    } else {
      // Update existing subject
      widget.subject!.name = _nameController.text.trim();
      widget.subject!.type = _selectedType;
      widget.subject!.minAttendance = double.parse(_minAttendanceController.text);
      widget.subject!.schedule = _schedule;
      widget.subject!.isMonthlyCalculation = _isMonthlyCalculation;
      widget.subject!.save();
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minAttendanceController.dispose();
    super.dispose();
  }
}

class _ScheduleDialog extends StatefulWidget {
  final Function(ScheduleItem) onScheduleAdded;

  const _ScheduleDialog({required this.onScheduleAdded});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  int _selectedDay = 1; // Monday
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Class Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day Selection
          DropdownButtonFormField<int>(
            value: _selectedDay,
            decoration: const InputDecoration(
              labelText: 'Day',
              border: OutlineInputBorder(),
            ),
            items: AppConstants.daysOfWeek.asMap().entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key + 1,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDay = value!;
              });
            },
          ),
          const SizedBox(height: UIConstants.spacingM),
          
          // Time Selection
          ListTile(
            title: const Text('Time'),
            subtitle: Text(_selectedTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) {
                setState(() {
                  _selectedTime = time;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final scheduleItem = ScheduleItem(
              dayOfWeek: _selectedDay,
              time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            );
            widget.onScheduleAdded(scheduleItem);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}