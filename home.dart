import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:not_pad/service/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const Home({super.key, required this.onThemeChanged});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isDarkMode = false;
  List<Map<String, dynamic>> allNotes = [];
  bool isLoadingNote = true;

  final TextEditingController noteTitleController = TextEditingController();
  final TextEditingController noteDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    reloadNotes();
    loadThemePreferences();
  }

  Future<void> loadThemePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void toggleTheme(bool value) async {
    setState(() {
      isDarkMode = value;
      widget.onThemeChanged(isDarkMode);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void reloadNotes() async {
    final notes = await QueryHelper.getAllNotes();
    setState(() {
      allNotes = notes;
      isLoadingNote = false;
    });
  }

  Future<void> addNote() async {
    try {
      await QueryHelper.createNote(
        noteTitleController.text,
        noteDescriptionController.text,
      );
      noteTitleController.clear();
      noteDescriptionController.clear();
      reloadNotes();
    } catch (e) {
      _showErrorSnackbar('Failed to add note: $e');
    }
  }

  Future<void> updateNote(int id) async {
    try {
      await QueryHelper.updateNote(
        id,
        noteTitleController.text,
        noteDescriptionController.text,
      );
      noteTitleController.clear();
      noteDescriptionController.clear();
      reloadNotes();
    } catch (e) {
      _showErrorSnackbar('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await QueryHelper.deleteNote(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note Deleted')));
      reloadNotes();
    } catch (e) {
      _showErrorSnackbar('Failed to delete note: $e');
    }
  }

  Future<void> deleteAllNotes() async {
    final noteCount = await QueryHelper.getNoteCount();
    if (noteCount > 0) {
      await QueryHelper.deleteAll();
      reloadNotes();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All Notes Deleted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Notes to Delete')));
    }
  }

  void showBottomSheetContent(int? id) {
    if (id != null) {
      final currentNote = allNotes.firstWhere((note) => note['id'] == id);
      noteTitleController.text = currentNote['title'];
      noteDescriptionController.text = currentNote['description'];
    }
    showModalBottomSheet(
      elevation: 1,
      isScrollControlled: true,
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 15,
            top: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: noteTitleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Title",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteDescriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Description",
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: OutlinedButton(
                  onPressed: () async {
                    if (id == null) {
                      await addNote();
                    } else {
                      await updateNote(id);
                    }
                    noteTitleController.clear();
                    noteDescriptionController.clear();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: Text(id == null ? "Add Note" : "Update Note"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void exitApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit'),
          content: const Text("Are you sure you want to exit?"),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            OutlinedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text("Exit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NOTE PAD",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: "JosefineSans",
          ),
        ),
        actions: [
          IconButton(onPressed: deleteAllNotes, icon: const Icon(Icons.delete_forever)),
          IconButton(onPressed: exitApp, icon: const Icon(Icons.exit_to_app)),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: isDarkMode,
              onChanged: toggleTheme,
            ),
          ),
        ],
      ),
      body: Center(
        child: isLoadingNote
            ? const CircularProgressIndicator()
            : allNotes.isEmpty
                ? const Text('No Notes Found', style: TextStyle(fontSize: 20))
                : ListView.builder(
                    itemCount: allNotes.length,
                    itemBuilder: (context, index) => Card(
                      margin: const EdgeInsets.all(15),
                      child: ListTile(
                        title: Text(
                          allNotes[index]["title"],
                          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          allNotes[index]["description"],
                          style: const TextStyle(fontSize: 20),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => showBottomSheetContent(allNotes[index]['id']),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => deleteNote(allNotes[index]['id']),
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheetContent(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
