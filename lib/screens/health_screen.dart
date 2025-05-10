import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  final TextEditingController _healthRecordController = TextEditingController();
  final TextEditingController _symptomSearchController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();

  List<Map<String, dynamic>> _healthRecords = [];
  final List<String> _selectedSymptoms = [];
  File? _selectedFile;
  final List<Map<String, dynamic>> _chatMessages = [];
  bool _isBotTyping = false;
  TimeOfDay? _reminderTime;
  String? _reminderFrequency;

  // Color palette
  final Color _primaryColor = const Color(0xFF5B9BD5);
  final Color _backgroundColor = const Color(0xFFF5F9FF);
  final Color _surfaceColor = Colors.white;
  final Color _secondaryColor = const Color(0xFF6C757D);

  // Predefined questions
  final List<String> _predefinedQuestions = [
    "Common symptoms of illness?",
    "Vaccination schedule?",
    "Signs my pet is in pain?",
    "Emergency symptoms?",
  ];

  // Symptom List
  final List<Map<String, dynamic>> _symptoms = [
    {"name": "Vomiting", "icon": Icons.sick},
    {"name": "Diarrhea", "icon": Icons.water_drop},
    {"name": "Lethargy", "icon": Icons.bed},
    {"name": "Coughing", "icon": Icons.speaker},
    {"name": "Loss of Appetite", "icon": Icons.no_meals},
  ];

  // Reminder frequencies
  final List<String> _frequencies = ['Once', 'Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadHealthRecords();
    _addBotMessage("Hello! I'm your pet health assistant. How can I help?");
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _notifications.initialize(initializationSettings);
  }

  void _addBotMessage(String message) {
    setState(() {
      _chatMessages.insert(0, {
        "role": "bot",
        "message": message,
        "time": DateTime.now(),
      });
    });
  }

  Future<void> _loadHealthRecords() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final querySnapshot = await _firestore
          .collection('health_records')
          .where('uid', isEqualTo: currentUser.uid)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _healthRecords = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'description': data['description'] ?? '',
            'date': (data['timestamp'] as Timestamp).toDate(),
            'symptoms': List<String>.from(data['symptoms'] ?? []),
            'medication': data['medication'] ?? '',
            'reminder': data['reminder'] ?? false,
          };
        }).toList();
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _scheduleReminder(String medication, DateTime date) async {
    if (_reminderTime == null || _reminderFrequency == null) return;

    final androidDetails = const AndroidNotificationDetails(
      'pet_medication',
      'Pet Medication Reminders',
      channelDescription: 'Reminders for pet medications',
      importance: Importance.high,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    DateTime scheduleTime = DateTime(
      date.year,
      date.month,
      date.day,
      _reminderTime!.hour,
      _reminderTime!.minute,
    );

    if (_reminderFrequency == 'Daily') {
      await _notifications.periodicallyShow(
        0,
        'Medication Reminder',
        'Time to give ${medication} to your pet',
        RepeatInterval.daily,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else if (_reminderFrequency == 'Weekly') {
      await _notifications.periodicallyShow(
        0,
        'Medication Reminder',
        'Time to give ${medication} to your pet',
        RepeatInterval.weekly,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      await _notifications.show(
        0,
        'Medication Reminder',
        'Time to give ${medication} to your pet',
        notificationDetails,
        payload: 'medication_reminder',
      );
    }
  }

  Future<void> _addHealthRecord() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && _healthRecordController.text.isNotEmpty) {
      final newRecord = {
        'uid': currentUser.uid,
        'description': _healthRecordController.text.trim(),
        'symptoms': _selectedSymptoms,
        'medication': _healthRecordController.text.contains('medication')
            ? _healthRecordController.text.trim()
            : '',
        'timestamp': FieldValue.serverTimestamp(),
        'reminder': _reminderTime != null,
      };

      await _firestore.collection('health_records').add(newRecord);

      if (_reminderTime != null &&
          _healthRecordController.text.toLowerCase().contains('medication')) {
        await _scheduleReminder(
          _healthRecordController.text.trim(),
          DateTime.now(),
        );
      }

      setState(() {
        _healthRecordController.clear();
        _selectedSymptoms.clear();
        _selectedFile = null;
        _reminderTime = null;
        _reminderFrequency = null;
      });

      _loadHealthRecords();
    }
  }

  Future<void> _pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _reminderTime = time;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatMessages.insert(0, {
        "role": "user",
        "message": message,
        "time": DateTime.now(),
      });
      _isBotTyping = true;
    });
    _chatController.clear();

    // Simulate bot response
    await Future.delayed(const Duration(seconds: 1));

    String response = _getBotResponse(message);
    _addBotMessage(response);
  }

  String _getBotResponse(String message) {
    message = message.toLowerCase();

    if (message.contains("symptom") || message.contains("illness")) {
      return "Common pet illness symptoms include vomiting, diarrhea, lethargy, and loss of appetite. If symptoms persist, consult your vet.";
    } else if (message.contains("vaccin")) {
      return "Core vaccines: dogs need rabies & distemper, cats need rabies & feline distemper. Your vet can provide a schedule.";
    } else if (message.contains("pain")) {
      return "Signs of pain: limping, vocalizing, appetite changes, or behavior changes. Cats often hide pain by hiding.";
    } else if (message.contains("emergency")) {
      return "Pet emergencies: difficulty breathing, seizures, uncontrolled bleeding. Contact your vet immediately!";
    } else {
      return "I'm your pet health assistant. For specific medical advice, please consult your veterinarian.";
    }
  }

  Widget _buildHealthRecordCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${record['date']?.toString().split(' ')[0] ?? 'No date'}",
                  style: TextStyle(
                    fontSize: 12,
                    color: _secondaryColor,
                  ),
                ),
                if (record['reminder'] == true)
                  Icon(Icons.notifications_active,
                      size: 16, color: _primaryColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              record['description'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (record['symptoms'] != null && record['symptoms'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: (record['symptoms'] as List).map((symptom) => Chip(
                  label: Text(symptom),
                  backgroundColor: _primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: _primaryColor,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Set Medication Reminder",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _secondaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _pickReminderTime,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _reminderTime != null
                      ? "${_reminderTime!.format(context)}"
                      : "Select Time",
                  style: TextStyle(color: _primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _reminderFrequency,
                hint: const Text("Frequency"),
                dropdownColor: _surfaceColor,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _frequencies
                    .map((frequency) => DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _reminderFrequency = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: _primaryColor,
              radius: 16,
              child: const Icon(Icons.pets, color: Colors.white, size: 16),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser ? _primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message['message'],
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
        title: const Text("Pet Health Records"),
    backgroundColor: _primaryColor,
    foregroundColor: Colors.white,
    bottom: TabBar(
    indicatorColor: Colors.white,
    tabs: const [
    Tab(icon: Icon(Icons.medical_services),
    ),
      Tab(icon: Icon(Icons.chat)),
    ],
    ),
    ),
    body: TabBarView(
    children: [
    // Health Records Tab
    SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    // Add Health Record Section
    Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    "Add New Record",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),
    TextField(
    controller: _healthRecordController,
    decoration: InputDecoration(
    labelText: "Description",
    hintText: "Describe condition or medication...",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: Colors.grey[50],
    ),
    maxLines: 3,
    ),
    const SizedBox(height: 12),
    const Text(
    "Select Symptoms:",
    style: TextStyle(fontWeight: FontWeight.w500),
    ),
    const SizedBox(height: 8),
    Wrap(
    spacing: 8,
    runSpacing: 8,
    children: _symptoms.map((symptom) => FilterChip(
    label: Text(symptom['name']),
    selected: _selectedSymptoms.contains(symptom['name']),
    onSelected: (selected) {
    setState(() {
    if (selected) {
    _selectedSymptoms.add(symptom['name']);
    } else {
    _selectedSymptoms.remove(symptom['name']);
    }
    });
    },
    backgroundColor: Colors.grey[200],
    selectedColor: _primaryColor.withOpacity(0.2),
    labelStyle: TextStyle(
    color: _selectedSymptoms.contains(symptom['name'])
    ? _primaryColor
        : Colors.black,
    ),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    ),
    )).toList(),
    ),
    const SizedBox(height: 12),
    if (_healthRecordController.text
        .toLowerCase()
        .contains('medication'))
    _buildReminderSection(),
    const SizedBox(height: 12),
    Row(
    children: [
    Expanded(
    child: OutlinedButton(
    onPressed: _pickFile,
    style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    ),
    ),
    child: const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.attach_file, size: 18),
    SizedBox(width: 8),
    Text("Add Attachment"),
    ],
    ),
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: ElevatedButton(
    onPressed: _addHealthRecord,
    style: ElevatedButton.styleFrom(
    backgroundColor: _primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    ),
    ),
    child: const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.save, size: 18),
    SizedBox(width: 8),
    Text("Save Record"),
    ],
    ),
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    ),
    const SizedBox(height: 24),
    // Health Records List
    const Text(
    "Health History",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 12),
    if (_healthRecords.isEmpty)
    Container(
    padding: const EdgeInsets.symmetric(vertical: 32),
    decoration: BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
    children: [
    Icon(
    Icons.medical_services,
    size: 48,
    color: Colors.grey[400],
    ),
    const SizedBox(height: 8),
    Text(
    "No health records yet",
    style: TextStyle(
    color: Colors.grey[600],
    ),
    ),
    ],
    ),
    ),
    if (_healthRecords.isNotEmpty)
    Column(
    children: _healthRecords.map(_buildHealthRecordCard).toList(),
    ),
    ],
    ),
    ),

    // Chat Assistant Tab
    Column(
    children: [
    Expanded(
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    children: [
    // Chat Messages
    Expanded(
    child: Container(
    decoration: BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(12),
    ),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: ListView.builder(
    reverse: true,
    padding: const EdgeInsets.all(12),
    itemCount: _chatMessages.length +
    (_isBotTyping ? 1 : 0),
    itemBuilder: (context, index) {
    if (_isBotTyping && index == 0) {
    return const Padding(
    padding: EdgeInsets.all(8.0),
    child: Row(
    children: [
    SizedBox(
    width: 24,
    height: 24,
    child: CircularProgressIndicator(
    strokeWidth: 2)),
    SizedBox(width: 8),
    Text("Assistant is typing..."),
    ],
    ),
    );
    }
    return _buildChatBubble(_chatMessages[
    _isBotTyping ? index - 1 : index]);
    },
    ),
    ),
    ),
    ),
    const SizedBox(height: 12),
    // Predefined Questions
    SizedBox(
    height: 40,
    child: ListView(
    scrollDirection: Axis.horizontal,
    children: _predefinedQuestions
        .map((question) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ActionChip(
    label: Text(question),
    onPressed: () {
    _chatController.text = question;
    _sendMessage();
    },
    backgroundColor: Colors.grey[200],
    shape: RoundedRectangleBorder(
    borderRadius:
    BorderRadius.circular(20),
    ),
    ),
    ))
        .toList(),
    ),
    ),
    const SizedBox(height: 12),
    // Message Input
    TextField(
    controller: _chatController,
    decoration: InputDecoration(
    hintText: "Ask about pet health...",
    suffixIcon: IconButton(
    icon: Icon(Icons.send, color: _primaryColor),
    onPressed: _sendMessage,
    ),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
    ),
    ),
    onSubmitted: (_) => _sendMessage(),
    ),
    ],
    ),
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    );
  }
}