<img src="https://github.com/Utopia-USS/utopia_cms/raw/master/packages/core/cms_core.png" width = "343" height = "159"/>

# Utopia CMS (Core)

The Utopia CMS Core package is a data visualization library written in Flutter for creating beautiful,
animated, high-performance and flexible CMS panels, which are used to manage databases for mobile apps.

<img src="https://github.com/Utopia-USS/utopia_cms/raw/master/packages/core/video.gif" width = "960" height = "425"/>

## Motivation

Creating CMS panels in Flutter can be costly compared to using No-Code/Low-Code solutions. However, we believe that it
is still beneficial for a project as it ensures maintainability and allows for the creation of outstanding UI, which is
often lacking in existing solutions. That's why we have developed this Low-Code library to optimize the process of
creating customizable panels.

## Example

This is a simple example which integrates with GraphQL server and creates complete CMS layout with one page and
management flow.

```dart
class Example extends StatelessWidget {
  final String? pageId;
  final void Function(String pageId) onPageChanged;
  final GraphQLClient client;

  const Example({required this.pageId, required this.onPageChanged, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CmsWidget(
        selectedPageId: MutableValue.delegate(() => pageId ?? 'users', onPageChanged),
        items: [
          CmsWidgetItem.page(
            id: 'products',
            icon: Icon(Icons.shopping_basket_outlined),
            title: Text('Products'),
            content: _buildProductsPage(),
          ),
        ],
      ),
    );
  }

  CmsTablePage _buildProductsPage() {
    return CmsTablePage(
      title: "Products",
      delegate: CmsHasura.delegate(
        client: client,
        table: Tables.products,
        fields: TableFields.products,
        archivedFilter: const CmsFilterNotEquals("archived", true),
      ),
      entries: [
        CmsTextEntry(key: "name", modifier: const CmsEntryModifier(sortable: true)),
        CmsTextEntry(key: "description", flex: 4),
      ],
    );
  }
}
```

## CMS overview & basic features

The utopia_cms_core library provides the following features for creating server-layer, responsive table-based pages,
edit/create flows, and internal navigation. It also supports integration with custom pages and offers a set of helpful
widgets to maintain a coherent theme in your application.

### CmsWidget

Wraps whole application and creates a proper paging behavior with usage of `CmsMenu`.

### CmsThemeData

Modifies the styling of the Widgets, determines fonts and colors.

### CmsTable

This is a standalone widget for table-based content management. By default, it displays a sortable and filterable table,
introduces 25 item infinite-scroll paging, creates edit and create subpages, and supports item removal. The data is
provided by `CmsDelegate` and displayed by `CmsEntry`. Requests may be filtered via `CmsFilterEntry`.

### CmsEntry

This interface handles the display and management of data. There is a pre-created set of primitives for interacting with
basic data types.

| Name                                                                                                                   | Description                                     |
|------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| [CmsTextEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsTextEntry-class.html)                     | Handles generic String variables                |
| [CmsNumEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsNumEntry-class.html)                       | Handles numeric variables                       |
| [CmsDropdownEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsDropdownEntry-class.html)             | For managing set of options and singular choice |
| [CmsBoolEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsBoolEntry-class.html)                     | Handles bool variables                          |
| [CmsDateEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsDateEntry-class.html)                     | Handles Date variables                          |
| [CmsMediaEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsMediaEntry-class.html)                   | Handles files (img, vid, doc, unknown)          |
| [CmsToManyDropdownEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsToManyDropdownEntry-class.html) | M2M relationships multi selection dropdown      |

You can create custom entries by referring to the implementation of any primitive and the
[CmsEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsEntry-class.html)

### CmsFilterEntry

This interface handles filtering fields of the CmsTable.

| Name                                                                                                               | Description                        |
|--------------------------------------------------------------------------------------------------------------------|------------------------------------|
| [CmsFilterSearchEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsFilterSearchEntry-class.html) | Handles generic String full search |
| [CmsFilterDateEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsFilterDateEntry-class.html)     | Handles date ranges                |

You can create custom entries by referring to the implementation of any primitive and the
[CmsFilterEntry](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsFilterEntry-class.html)

### CmsDelegate

This is the main interface for handling  `CmsTable`. It is not suitable on its own for handling to-many relationships.
To achieve this functionality, refer to [Relationships](#Relationships)

The library provides pre-created delegates:

| Name                                                                | Description                          |
|---------------------------------------------------------------------|--------------------------------------|
| [utopia_cms_firebase](https://pub.dev/packages/utopia_cms_firebase) | Firebase delegate integration        |
| [utopia_cms_graphql](https://pub.dev/packages/utopia_cms_graphql)   | Generic GraphQL delegate integration |
| [utopia_cms_hasura](https://pub.dev/packages/utopia_cms_hasura)     | Hasura delegate integration          |

To create your custom delegate, refer to the implementation of any delegate and the
[CmsDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsDelegate-class.html) interface.

## Relationships

Handling relation-based entries in the system is slightly more complex. For a particular entry, you need to use
the [CmsToManyDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsToManyDelegate-class.html)
and register additional callbacks to `CmsItemManagementBaseState` that is available via `Provider`

```
final baseState = Provider.of<CmsItemManagementBaseState>(context);

baseState.addOnSavedCallback(
    (value) async {
        return delegate.update(...);
    }
);
```

The library provides the following existing solutions for relationships:

| Existing `CmsToManyDelegate` implementations                | Source                                                          |
|-------------------------------------------------------------|-----------------------------------------------------------------|
| `CmsHasuraOneToManyDelegate`, `CmsHasuraManyToManyDelegate` | [utopia_cms_hasura](https://pub.dev/packages/utopia_cms_hasura) |

## Media

Media such as images or videos are
handled by [CmsMediaDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsMediaDelegate-class.html)
which introduces upload and delete functions.

The library provides no existing generic solutions for relationships yet, but here's an example

```
class FileDelegate implements CmsMediaDelegate {
  final CmsGraphQLService graphQLService;
  final GraphQLClient client;

  const FileDelegate(this.graphQLService, this.client);

  Future<({String downloadUrl, CmsFileRef ref})> upload(XFile file) async {
    final (uploadUrl, downloadUrl) = await _createAttachment(mimeType: file.mimeType!);
    await _upload(uploadUrl, file);
    return (downloadUrl: downloadUrl, ref: "XD");
  }

  Future<(String, String)> _createAttachment({required String mimeType}) async {
    final result = await graphQLService.mutate(
      client,
      name: 'createAttachment',
      arguments: {'data': {'contentType': mimeType}.toValueNodeUnsafe()},
      fields: {CmsGraphQLField('uploadUrl'), CmsGraphQLField('downloadUrl')},
    );
    result as Map<String, dynamic>;
    return (result['uploadUrl'] as String, result['downloadUrl'] as String);
  }

  Future<void> _upload(String url, XFile file) async {
    final webFile = await HttpRequest.request(file.path, responseType: 'blob');
    final request = await HttpRequest.request(url, method: 'PUT', mimeType: file.mimeType!, sendData: webFile.response);
    if(request.status != HttpStatus.ok) throw Exception("Failed to upload");
  }
}
```

## Widgets

The package exports its basic UI components in order to allow maintaining a coherent theme in your custom pages.

* **CmsFieldWrapper**
* **CmsTextField**
* **CmsButton**
* **CmsSwitch**
* **CmsLoader**
* **CmsMockLoadingBox**
* **CmsHeader**

## Contributions

Contributions are welcomed!

If you want to support our project, feel free to open a pull-request.


