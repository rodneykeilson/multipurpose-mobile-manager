import 'package:flutter/material.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> _contacts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  Future<void> _getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
      });
    } else {
      // Handle the case when permission is not granted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('permissionDenied'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _contacts
        .where((contact) =>
            contact.displayName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('contact')),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ContactSearchDelegate(_contacts),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = filteredContacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: contact.photo != null
                  ? MemoryImage(contact.photo!)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            title: Text(contact.displayName),
            subtitle: Text(contact.emails.isNotEmpty
                ? contact.emails.first.address
                : ''),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailPage(contact: contact),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ContactDetailPage extends StatelessWidget {
  final Contact contact;

  ContactDetailPage({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.displayName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: contact.photo != null
                    ? MemoryImage(contact.photo!)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('name'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(contact.displayName),
            SizedBox(height: 16),
            if (contact.emails.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('email'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(contact.emails.first.address),
                  SizedBox(height: 16),
                ],
              ),
            if (contact.phones.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('phoneNumber'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(contact.phones.first.number),
                  SizedBox(height: 16),
                ],
              ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${AppLocalizations.of(context).translate('calling')} ${contact.displayName}...')),
                );
              },
              icon: Icon(Icons.phone),
              label: Text(AppLocalizations.of(context).translate('call')),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactSearchDelegate extends SearchDelegate {
  final List<Contact> contacts;

  ContactSearchDelegate(this.contacts);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = contacts
        .where((contact) =>
            contact.displayName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final contact = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: contact.photo != null
                ? MemoryImage(contact.photo!)
                : AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
          title: Text(contact.displayName),
          subtitle: Text(contact.emails.isNotEmpty
              ? contact.emails.first.address
              : ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactDetailPage(contact: contact),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = contacts
        .where((contact) =>
            contact.displayName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final contact = suggestions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: contact.photo != null
                ? MemoryImage(contact.photo!)
                : AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
          title: Text(contact.displayName),
          subtitle: Text(contact.emails.isNotEmpty
              ? contact.emails.first.address
              : ''),
          onTap: () {
            query = contact.displayName;
            showResults(context);
          },
        );
      },
    );
  }
}
