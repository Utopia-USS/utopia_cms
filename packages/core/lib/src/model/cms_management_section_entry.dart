import 'package:flutter/material.dart';
import 'package:utopia_cms/utopia_cms.dart';

class CmsManagementSectionEntry {
  final String title;
  final bool showEdit, showCreate;
  final Widget Function(JsonMap?, bool isEdit) sliverBuilder;

  CmsManagementSectionEntry({
    this.showEdit = true,
    this.showCreate = false,
    required this.title,
    required this.sliverBuilder,
  });
}
