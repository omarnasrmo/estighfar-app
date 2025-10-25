import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(EstighfarApp());
}

class EstighfarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كم فاتك من الاستغفار',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        fontFamily: 'Arial',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? birthDate;
  int totalRequired = 0;
  int remaining = 0;
  bool loaded = false;

  static const String prefBirth = 'birthDate';
  static const String prefRemaining = 'remaining';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    final birthMillis = sp.getInt(prefBirth);
    final rem = sp.getInt(prefRemaining);

    setState(() {
      if (birthMillis != null) birthDate = DateTime.fromMillisecondsSinceEpoch(birthMillis);
      if (rem != null) remaining = rem;
      loaded = true;
    });

    _recalculate();
  }

  Future<void> _savePrefs() async {
    final sp = await SharedPreferences.getInstance();
    if (birthDate != null) {
      await sp.setInt(prefBirth, birthDate!.millisecondsSinceEpoch);
    }
    await sp.setInt(prefRemaining, remaining);
  }

  void _recalculate() {
    if (birthDate == null) {
      setState(() {
        totalRequired = 0;
        if (remaining == 0) remaining = 0;
      });
      return;
    }

    final pubertyDate = DateTime(birthDate!.year + 15, birthDate!.month, birthDate!.day);
    final today = DateTime.now();
    final daysSincePuberty = today.isBefore(pubertyDate) ? 0 : today.difference(pubertyDate).inDays;
    final total = daysSincePuberty * 70;

    setState(() {
      totalRequired = total;
      if (remaining == 0 || remaining > total) remaining = total;
    });

    _savePrefs();
  }

  Future<void> _pickBirthDate() async {
    final initial = birthDate ?? DateTime.now().subtract(Duration(days: 365 * 20));
    final newDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );

    if (newDate != null) {
      setState(() {
        birthDate = newDate;
      });
      _recalculate();
    }
  }

  void _changeRemaining(int delta) {
    setState(() {
      remaining = (remaining - delta).clamp(0, totalRequired);
    });
    _savePrefs();
  }

  void _addToRemaining(int delta) {
    setState(() {
      remaining = (remaining + delta).clamp(0, totalRequired);
    });
    _savePrefs();
  }

  void _resetAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تأكيد إعادة الضبط'),
        content: Text('هل تريد إعادة ضبط تاريخ الميلاد وعداد الاستغفار؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('نعم')),
        ],
      ),
    );
    if (confirm == true) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(prefBirth);
      await sp.remove(prefRemaining);
      setState(() {
        birthDate = null;
        totalRequired = 0;
        remaining = 0;
      });
    }
  }

  String _formatDate(DateTime d) {
    return DateFormat.yMMMMd('ar').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final pubertyDateStr = birthDate == null ? '-' : _formatDate(DateTime(birthDate!.year + 15, birthDate!.month, birthDate!.day));
    final birthStr = birthDate == null ? 'لم يتم التحديد' : _formatDate(birthDate!);
    final percent = totalRequired == 0 ? 0.0 : (1 - (remaining / totalRequired)).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('كم فاتك من الاستغفار'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'إعادة ضبط',
            onPressed: _resetAll,
          )
        ],
      ),
      body: loaded ? SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('تاريخ الميلاد:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: Text(birthStr, style: TextStyle(fontSize: 16))),
                ElevatedButton(onPressed: _pickBirthDate, child: Text('اختر تاريخ الميلاد')),
              ],
            ),
            SizedBox(height: 12),
            Text('تاريخ بداية السن (البلوغ = بعد 15 سنة):', style: TextStyle(fontSize: 16)),
            SizedBox(height: 6),
            Text(pubertyDateStr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('المجموع المطلوب من الاستغفار منذ البلوغ', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 6),
                    Text('$totalRequired', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(value: percent),
                    SizedBox(height: 8),
                    Text('المتبقي الآن', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 6),
                    Text('$remaining', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 18),
            Text('أدوات التتبع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: remaining > 0 ? () => _changeRemaining(1) : null,
                  icon: Icon(Icons.remove),
                  label: Text('استغفار -1'),
                ),
                ElevatedButton.icon(
                  onPressed: remaining > 4 ? () => _changeRemaining(5) : null,
                  icon: Icon(Icons.remove_circle),
                  label: Text('استغفار -5'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final n = await _showNumberInput(context, 'أضف استغفار (عدد)', 1);
                    if (n != null && n > 0) _changeRemaining(n);
                  },
                  icon: Icon(Icons.exposure_minus_1),
                  label: Text('خصم مخصص'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final n = await _showNumberInput(context, 'تعويض/إضافة استغفار (عدد)', 1);
                    if (n != null && n > 0) _addToRemaining(n);
                  },
                  icon: Icon(Icons.add),
                  label: Text('إضافة'),
                ),
                OutlinedButton.icon(
                  onPressed: _recalculate,
                  icon: Icon(Icons.calculate),
                  label: Text('أعد الحساب الآن'),
                ),
              ],
            ),

            SizedBox(height: 20),
            Text('ملاحظات', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              '• الحساب يفترض 70 استغفار/يوم لكل أيام ما بعد سن 15.\n'
              '• يمكنك تغيير تاريخ الميلاد في أي وقت وسيتم إعادة حساب المجموع.\n'
              '• التطبيق يخزن المتبقي محليًا على جهازك فقط.',
            ),

            SizedBox(height: 24),
            Center(
              child: Text('بسم الله الرحمن الرحيم', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            SizedBox(height: 40),
          ],
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }

  Future<int?> _showNumberInput(BuildContext context, String title, int initial) async {
    final controller = TextEditingController(text: initial.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'أدخل رقماً صحيحاً'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: Text('إلغاء')),
          TextButton(onPressed: () {
            final v = int.tryParse(controller.text);
            Navigator.pop(context, v);
          }, child: Text('موافق')),
        ],
      ),
    );
    return result;
  }
}
