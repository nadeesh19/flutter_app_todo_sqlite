import 'package:flutter/material.dart';
import 'package:flutter_app/models/note.dart';
import 'package:flutter_app/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetails(this.note, this.appBarTitle);

  @override
  _NoteDetailsState createState() =>
      _NoteDetailsState(this.note, this.appBarTitle);
}

class _NoteDetailsState extends State<NoteDetails> {
  static var _properties = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  // these controllers for control to values given by user
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailsState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: () {
        // write some code to control things, when user press back navigation button in device
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // write some code to control things, when user press back button in Appbar
                moveToLastScreen();
              }),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 15.0, right: 10.0),
          child: ListView(
            // static List View
            children: <Widget>[
              // First Element
              DropdownButton(
                  items: _properties.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint('===== UserS Selected : $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  }),

              // Second Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (titleValue) {
                    debugPrint('=== text Title Changes : $titleValue');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              // Third Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (descValue) {
                    debugPrint('=== text Desc Changes : $descValue');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              // Fourth Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            debugPrint('======== Save Clicked =====');
                            _save();
                          });
                        },
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            debugPrint('======== Delete Clicked =====');
                            _delete();
                          });
                        },
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //  convert the String priority in the form of Integer before saving it to database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //  convert Int priority to String priority and display it to User in Drop Down
  String getPriorityAsString(int value) {
    String priority;

    switch (value) {
      case 1:
        priority = _properties[0]; // 'High'
        break;
      case 2:
        priority = _properties[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to Database
  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (note.id != null) {
      // Case 01: Update Operation
      result = await helper.updateNote(note);
    } else {
      // Case 02: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note saved Successfully!');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem! Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // CASE 01: IF USER IS TRYING TO DELETE THE NewNote i.e.
    // User has come to the DetailsPage by pressing the FAB of NoteList page
    if(note.id == null){
      _showAlertDialog('Status', 'No Note was deleted!');
      return; //  dont execute the code further
    }

    // CASE 02: User is trying to delete the old note that already has a valid ID
    int result = await helper.deleteNote(note.id);

    if(result != 0){
      _showAlertDialog('Status', 'Note saved Successfully!');
    } else {
      // Failure
      _showAlertDialog('Status', 'ERROR Occured while deleting Note');
    }

  }

  // Alert message
  void _showAlertDialog(String alertTitle, String alertMessage) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(alertTitle),
      content: Text(alertMessage),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }
}
