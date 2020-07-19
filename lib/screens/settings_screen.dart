import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tweety_mobile/blocs/auth_profile/auth_profile_bloc.dart';
import 'package:tweety_mobile/screens/account_settings_screen.dart';
import 'package:tweety_mobile/widgets/loading_indicator.dart';
import 'package:tweety_mobile/widgets/settings_list_tile.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: BackButton(
            color: Colors.black,
          ),
          title: Text(
            'Settings',
            style: Theme.of(context).appBarTheme.textTheme.caption,
          ),
          centerTitle: true,
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        ),
        body: BlocBuilder<AuthProfileBloc, AuthProfileState>(
          builder: (context, state) {
            if (state is AuthProfileLoading) {
              return LoadingIndicator();
            }
            if (state is AuthProfileLoaded) {
              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                children: <Widget>[
                  Text(
                    '@' + state.user.username,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 15.0),
                  settingsListTile(context, 'Account',
                      heroTag: 'settings__account', onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AccountSettingsScreen(user: state.user),
                      ),
                    );
                  })
                ],
              );
            }
            return Container();
          },
        ));
  }
}
