import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.terms_of_service),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.terms_of_service,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              AppLocalizations.of(context)!.definitions_heading,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '${AppLocalizations.of(context)!.definitions_app} ${AppLocalizations.of(context)!.definitions_trainer} ${AppLocalizations.of(context)!.definitions_student}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Text(
              AppLocalizations.of(context)!.terms_of_use_heading,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '${AppLocalizations.of(context)!.terms_of_use_agreement} ${AppLocalizations.of(context)!.terms_of_use_compliance}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Text(
              AppLocalizations.of(context)!.trainer_responsibilities_heading,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '${AppLocalizations.of(context)!.trainer_responsibilities_quality} ${AppLocalizations.of(context)!.trainer_responsibilities_confidentiality}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Text(
              AppLocalizations.of(context)!.student_responsibilities_heading,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '${AppLocalizations.of(context)!.student_responsibilities_usage} ${AppLocalizations.of(context)!.student_responsibilities_account_security}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Text(
              AppLocalizations.of(context)!.confidentiality_data_protection_heading,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '${AppLocalizations.of(context)!.confidentiality_data_protection_confidentiality} ${AppLocalizations.of(context)!.confidentiality_data_protection_usage}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Text(
              AppLocalizations.of(context)!.changes_to_terms_heading,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '${AppLocalizations.of(context)!.changes_to_terms_administration_rights} ${AppLocalizations.of(context)!.changes_to_terms_effective_date}',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}