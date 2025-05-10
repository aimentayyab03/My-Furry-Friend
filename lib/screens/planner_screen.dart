import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final List<Map<String, String>> _tasks = [];
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
  TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final Map<DateTime, List<Map<String, String>>> _appointments = {};
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  int _notificationIdCounter = 0;

  // Pet theme colors
  final Color _primaryColor = const Color(0xFF7B5FA6); // Soft purple
  final Color _secondaryColor = const Color(0xFFFFA5B0); // Soft pink
  final Color _accentColor = const Color(0xFF6EC6CA); // Teal
  final Color _backgroundColor = const Color(0xFFF9F4FF); // Light lavender
  final Color _cardColor = const Color(0xFFFFFAF8); // Soft cream

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones(); // Initialize timezone data
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  void _scheduleNotification(
      String title, String body, DateTime scheduledTime) async {
    final tz.TZDateTime scheduledDate =
    tz.TZDateTime.from(scheduledTime, tz.local);

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'appointment_channel_id',
      'Appointments',
      channelDescription: 'Notification for scheduled appointments',
      importance: Importance.max,
      priority: Priority.high,
    );

    const platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      _notificationIdCounter++, // Unique notification ID
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        title: Row(
          children: [
            Icon(Icons.pets, color: _cardColor),
            const SizedBox(width: 10),
            const Text(
              'Pet Planner',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _cardColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_secondaryColor, _accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white),
                        const SizedBox(width: 10),
                        const Text(
                          'Pet Activities Calendar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Keep track of your pet\'s activities, vet visits, playtime, and more!',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Calendar with customized style
              Container(
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: TableCalendar(
                  focusedDay: _selectedDate,
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  eventLoader: (day) => _appointments[day] ?? [],
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      color: _primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: _primaryColor,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: _primaryColor,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: _secondaryColor.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: _accentColor,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: _secondaryColor),
                    outsideTextStyle: const TextStyle(color: Colors.grey),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendStyle: TextStyle(
                      color: _secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Task List for the Selected Date with pet-themed decoration
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.task_alt, color: _primaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'Events on ${DateFormat.yMMMd().format(_selectedDate)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _appointments[_selectedDate]?.isEmpty ?? true
                        ? Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.pets,
                            size: 40,
                            color: _secondaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No activities for your pet today!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _appointments[_selectedDate]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final task = _appointments[_selectedDate]?[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: index % 2 == 0
                              ? _primaryColor.withOpacity(0.1)
                              : _secondaryColor.withOpacity(0.1),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundColor: index % 2 == 0
                                  ? _primaryColor
                                  : _secondaryColor,
                              child: Icon(
                                _getTaskIcon(task?['title'] ?? ''),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              task?['title'] ?? 'No Title',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                task?['description'] ?? 'No Description',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete,
                                  color: _secondaryColor),
                              onPressed: () {
                                setState(() {
                                  _appointments[_selectedDate]
                                      ?.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: _secondaryColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // Get icon based on task title
  IconData _getTaskIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('vet') || lowerTitle.contains('doctor')) {
      return Icons.medical_services;
    } else if (lowerTitle.contains('walk') || lowerTitle.contains('exercise')) {
      return Icons.directions_walk;
    } else if (lowerTitle.contains('feed') || lowerTitle.contains('food')) {
      return Icons.restaurant;
    } else if (lowerTitle.contains('groom') || lowerTitle.contains('bath')) {
      return Icons.shower;
    } else if (lowerTitle.contains('medicine') || lowerTitle.contains('pill')) {
      return Icons.medication;
    } else {
      return Icons.pets;
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime notificationTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        return SingleChildScrollView(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.add_task, color: _primaryColor),
                const SizedBox(width: 10),
                Text(
                  'Add Pet Activity',
                  style: TextStyle(color: _primaryColor),
                ),
              ],
            ),
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskTitleController,
                    decoration: InputDecoration(
                      labelText: 'Activity Title',
                      labelStyle: TextStyle(color: _primaryColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _primaryColor),
                      ),
                      prefixIcon: Icon(Icons.title, color: _primaryColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _taskDescriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: _primaryColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _primaryColor),
                      ),
                      prefixIcon:
                      Icon(Icons.description, color: _primaryColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: const Text('Pick Time'),
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: _primaryColor,
                                onPrimary: Colors.white,
                                onSurface: _primaryColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedTime = pickedTime;
                          notificationTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          );
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: () {
                  if (_taskTitleController.text.isNotEmpty &&
                      _taskDescriptionController.text.isNotEmpty) {
                    setState(() {
                      if (_appointments[_selectedDate] == null) {
                        _appointments[_selectedDate] = [];
                      }
                      _appointments[_selectedDate]!.add({
                        'title': _taskTitleController.text,
                        'description': _taskDescriptionController.text,
                      });
                    });
                    _scheduleNotification(
                      _taskTitleController.text,
                      _taskDescriptionController.text,
                      notificationTime,
                    );
                    _taskTitleController.clear();
                    _taskDescriptionController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}