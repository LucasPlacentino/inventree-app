
import 'package:InvenTree/api.dart';
import 'package:InvenTree/inventree/company.dart';
import 'package:InvenTree/widget/dialogs.dart';
import 'package:InvenTree/widget/drawer.dart';
import 'package:InvenTree/widget/fields.dart';
import 'package:InvenTree/widget/refreshable_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompanyDetailWidget extends StatefulWidget {

  final InvenTreeCompany company;

  CompanyDetailWidget(this.company, {Key key}) : super(key: key);

  @override
  _CompanyDetailState createState() => _CompanyDetailState(company);

}


class _CompanyDetailState extends RefreshableState<CompanyDetailWidget> {

  final InvenTreeCompany company;

  final _editCompanyKey = GlobalKey<FormState>();

  @override
  String getAppBarTitle(BuildContext context) => I18N.of(context).company;

  @override
  Future<void> request(BuildContext context) async {
    await company.reload(context);
  }

  _CompanyDetailState(this.company) {
    // TODO
  }

  void _saveCompany(Map<String, String> values) async {
    Navigator.of(context).pop();

    var response = await company.update(context, values: values);

    refresh();
  }

  void editCompanyDialog() {

    // Values which can be edited
    var _name;
    var _description;
    var _website;

    showFormDialog(I18N.of(context).edit,
        key: _editCompanyKey,
        actions: <Widget>[
          FlatButton(
            child: Text(I18N.of(context).cancel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text(I18N.of(context).save),
            onPressed: () {
              if (_editCompanyKey.currentState.validate()) {
                _editCompanyKey.currentState.save();

                _saveCompany({
                  "name": _name,
                  "description": _description,
                  "website": _website,
                });
              }
            },
          ),
        ],
        fields: <Widget>[
          StringField(
            label: I18N.of(context).name,
            initial: company.name,
            onSaved: (value) {
              _name = value;
            },
          ),
          StringField(
            label: I18N.of(context).description,
            initial: company.description,
            onSaved: (value) {
              _description = value;
            },
          ),
          StringField(
            label: I18N.of(context).website,
            initial: company.website,
            allowEmpty: true,
            onSaved: (value) {
              _website = value;
            },
          )
        ]
    );
  }

  List<Widget> _companyTiles() {

    var tiles = List<Widget>();

    bool sep = false;

    tiles.add(Card(
      child: ListTile(
        title: Text("${company.name}"),
        subtitle: Text("${company.description}"),
        leading: InvenTreeAPI().getImage(company.image),
        trailing: IconButton(
          icon: FaIcon(FontAwesomeIcons.edit),
          onPressed: editCompanyDialog,
        ),
      ),
    ));

  if (company.website.isNotEmpty) {
    tiles.add(ListTile(
      title: Text("${company.website}"),
      leading: FaIcon(FontAwesomeIcons.globe),
      onTap: () {
        // TODO - Open website
      },
    ));

    sep = true;
  }

  if (company.email.isNotEmpty) {
    tiles.add(ListTile(
      title: Text("${company.email}"),
      leading: FaIcon(FontAwesomeIcons.at),
      onTap: () {
        // TODO - Open email
      },
    ));

    sep = true;
  }

  if (company.phone.isNotEmpty) {
    tiles.add(ListTile(
      title: Text("${company.phone}"),
      leading: FaIcon(FontAwesomeIcons.phone),
      onTap: () {
        // TODO - Call phone number
      },
    ));

    sep = true;
  }

    // External link
    if (company.link.isNotEmpty) {
      tiles.add(ListTile(
        title: Text("${company.link}"),
        leading: FaIcon(FontAwesomeIcons.link),
        onTap: () {
          // TODO - Open external link
        },
      ));

      sep = true;
    }

    if (sep) {
      tiles.add(Divider());
    }

    if (company.isSupplier) {
      // TODO - Add list of supplier parts
      // TODO - Add list of purchase orders

      tiles.add(Divider());
    }

    if (company.isCustomer) {

      // TODO - Add list of sales orders

      tiles.add(Divider());
    }

    if (company.notes.isNotEmpty) {
      tiles.add(ListTile(
        title: Text(I18N.of(context).notes),
        leading: FaIcon(FontAwesomeIcons.stickyNote),
        onTap: null,
      ));
    }

    return tiles;
  }

  @override
  Widget getBody(BuildContext context) {

    return Center(
      child: ListView(
        children: _companyTiles(),
      )
    );
  }
}