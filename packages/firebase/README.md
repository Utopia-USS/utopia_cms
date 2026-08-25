<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-cms-workspace/master/packages/firebase/cms_firebase.png" width="302" alt="Utopia CMS Firebase"/>

# Utopia CMS Firebase

Firebase implementation of the server-layer for [utopia_cms](https://pub.dev/packages/utopia_cms)

## Features

### CmsFirebaseDelegate

An implementation of
the [CmsDelegate](https://pub.dev/documentation/utopia_cms/latest/utopia_cms/CmsDelegate-class.html) interface.

Known limitations: sorting and filtering are not applied (override `get` to
support them), and paging is offset-based, so page N costs `offset + limit`
document reads. For large collections override `get` with
`startAfterDocument` cursor paging.

## Contributions

Contributions are welcomed! 

If you want to support our project, feel free to open a pull-request.


