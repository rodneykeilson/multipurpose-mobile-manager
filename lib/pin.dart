import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String pin = '';
  String correctPin = '';
  String newPin = '';
  final int pinLength = 6;
  bool isSettingPin = false;
  bool isConfirmingPin = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      correctPin = prefs.getString('userPin') ?? '';
      isSettingPin = correctPin.isEmpty;
    });
  }

  Future<void> _savePin(String newPin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPin', newPin);
    setState(() {
      correctPin = newPin;
      isSettingPin = false;
      isConfirmingPin = false;
    });
  }

  void addDigit(String digit) {
    if (pin.length < pinLength) {
      setState(() {
        pin += digit;
      });
    }

    if (pin.length == pinLength) {
      if (isSettingPin) {
        if (isConfirmingPin) {
          if (pin == newPin) {
            _savePin(pin);
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).translate('incorrectPIN'))),
            );
            setState(() {
              pin = '';
              newPin = '';
              isConfirmingPin = false;
            });
          }
        } else {
          setState(() {
            newPin = pin;
            pin = '';
            isConfirmingPin = true;
          });
        }
      } else if (pin == correctPin) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('incorrectPIN'))),
        );
        setState(() {
          pin = '';
        });
      }
    }
  }

  void removeDigit() {
    if (pin.isNotEmpty) {
      setState(() {
        pin = pin.substring(0, pin.length - 1);
      });
    }
  }

  Future<void> _resetPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userPin');
    setState(() {
      correctPin = '';
      isSettingPin = true;
      pin = '';
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!isSettingPin)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetPin,
            ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: correctPin.isEmpty && !isSettingPin
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSettingPin
                          ? isConfirmingPin
                              ? AppLocalizations.of(context).translate('confirmPIN')
                              : AppLocalizations.of(context).translate('setNewPIN')
                          : AppLocalizations.of(context).translate('inputCode'),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // Indikator PIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pinLength,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < pin.length
                                ? Colors.brown
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Keypad untuk PIN
                    SizedBox(
                      height: 350,
                      child: AspectRatio(
                        aspectRatio: 3 / 5,
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          children: [
                            // Tombol angka 1 - 9
                            ...List.generate(
                              9,
                              (index) => NumberButton(
                                number: '${index + 1}',
                                onTap: () => addDigit('${index + 1}'),
                              ),
                            ),
                            const SizedBox(), // Placeholder
                            // Tombol angka 0
                            NumberButton(
                              number: '0',
                              onTap: () => addDigit('0'),
                            ),
                            // Tombol hapus
                            DeleteButton(onTap: removeDigit),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Widget Tombol Angka
class NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onTap;

  const NumberButton({
    Key? key,
    required this.number,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

// Widget Tombol Hapus
class DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const DeleteButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      child: const Icon(Icons.backspace_outlined, size: 24),
    );
  }
}
