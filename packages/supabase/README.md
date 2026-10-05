<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-cms-workspace/master/packages/supabase/docs/header.png" width="313" alt="Utopia CMS Supabase"/>

# Utopia CMS Supabase

Supabase implementation of the server-layer for [utopia_cms](https://pub.dev/packages/utopia_cms)

## Features

### CmsSupabase

Provides a set of methods necessary to connect `CmsTable` to a Supabase back-end.

| Name                 | Description                                                    | 
|----------------------|----------------------------------------------------------------|
| `delegate`           | Creates a `CmsSupabaseDelegate`                                |
| `oneToManyDelegate`  | Creates an implementation of the `CmsSupabaseOneToManyDelegate` |
| `manyToManyDelegate` | Creates an implementation of the `CmsSupabaseManyToManyDelegate` |

### CmsSupabaseDelegate

An implementation of
the [CmsDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsDelegate-class.html) interface.

### CmsSupabaseManyToManyDelegate

An implementation of
the [CmsToManyDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsToManyDelegate-class.html)
interface for
many-to-many relationships.

### CmsSupabaseOneToManyDelegate

An implementation of
the [CmsToManyDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsToManyDelegate-class.html)
interface for
one-to-many relationships.

## Usage

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms_supabase/utopia_cms_supabase.dart';

// Initialize Supabase client
final supabase = Supabase.instance.client;

// Create delegate
final delegate = CmsSupabaseDelegate(
  const CmsSupabaseService(),
  client: supabase,
  table: const CmsSupabaseDataTable('users', idKey: 'id'),
);

// Use in CMS
CmsTablePage(
  title: 'Users',
  delegate: delegate,
  entries: [...],
)
```

## Contributions

Contributions are welcomed! 

If you want to support our project, feel free to open a pull-request.

