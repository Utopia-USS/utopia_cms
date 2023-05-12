# Utopia CMS Hasura

Hasura implementation of the server-layer for [utopia_cms](https://pub.dev/packages/utopia_cms)

## Features

### CmsHasura

Provides a set of handful methods necessary to connect `CmsTable` to a Hasura back-end.

| Name                 | Description                                                    | 
|----------------------|----------------------------------------------------------------|
| `createAdminClient`  | Creates a GraphQLClient                                        |
| `delegate`           | Creates a `CmsHasuraDelegate`                                  |
| `oneToManyDelegate`  | Creates an implementation of the `CmsHasuraOneToManyDelegate`  |
| `manyToManyDelegate` | Creates an implementation of the `CmsHasuraManyToManyDelegate` |

### CmsHasuraDelegate

An implementation of
the [CmsDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsDelegate-class.html) interface.

### CmsHasuraManyToManyDelegate

An implementation of
the [CmsToManyDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsToManyDelegate-class.html)
interface for
many-to-many relationships.

### CmsHasuraOneToManyDelegate

An implementation of
the [CmsToManyDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsToManyDelegate-class.html)
interface for
one-to-many relationships.

## Contributions

Contributions are welcomed! 

If you want to support our project, feel free to open a pull-request.


