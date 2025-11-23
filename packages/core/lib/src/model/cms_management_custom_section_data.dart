import 'package:flutter/material.dart';
import 'package:utopia_cms/utopia_cms.dart';

class CmsManagementCustomSectionData {
  final String title;
  final bool showEdit, showCreate;
  final Widget Function(JsonMap?, bool isEdit) sliverBuilder;

  CmsManagementCustomSectionData({
    this.showEdit = true,
    this.showCreate = false,
    required this.title,
    required this.sliverBuilder,
  });
}
